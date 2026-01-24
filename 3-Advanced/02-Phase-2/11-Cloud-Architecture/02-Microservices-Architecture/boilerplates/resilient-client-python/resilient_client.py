"""
Resilient HTTP Client
=====================

Production-grade HTTP client with:
- Circuit Breaker (pybreaker)
- Retry with Exponential Backoff (tenacity)
- Connection Pooling
- Timeout Handling
- Metrics Tracking

Author: DevOps Advanced Curriculum
License: MIT
"""

import logging
import time
from typing import Any, Dict, Optional
from dataclasses import dataclass, field

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry as Urllib3Retry
from pybreaker import CircuitBreaker, CircuitBreakerListener
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type,
    before_sleep_log
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


# Custom Exceptions
class CircuitBreakerError(Exception):
    """Raised when circuit breaker is open"""
    pass


class MaxRetriesExceeded(Exception):
    """Raised when max retries are exceeded"""
    pass


@dataclass
class ClientMetrics:
    """Metrics for the resilient client"""
    total_requests: int = 0
    successful_requests: int = 0
    failed_requests: int = 0
    circuit_open_count: int = 0
    retry_count: int = 0
    total_duration_ms: float = 0.0

    @property
    def success_rate(self) -> float:
        """Calculate success rate percentage"""
        if self.total_requests == 0:
            return 0.0
        return (self.successful_requests / self.total_requests) * 100

    @property
    def avg_duration_ms(self) -> float:
        """Calculate average request duration"""
        if self.total_requests == 0:
            return 0.0
        return self.total_duration_ms / self.total_requests


class CircuitBreakerListenerImpl(CircuitBreakerListener):
    """Custom circuit breaker listener for logging"""

    def state_change(self, cb, old_state, new_state):
        logger.warning(
            f"Circuit Breaker state changed from {old_state.name} to {new_state.name}"
        )


class ResilientClient:
    """
    Resilient HTTP client with circuit breaker and retry logic
    
    Features:
    - Automatic retries with exponential backoff
    - Circuit breaker to prevent cascading failures
    - Connection pooling for performance
    - Request/response logging
    - Metrics tracking
    
    Example:
        >>> client = ResilientClient(base_url='http://api.example.com')
        >>> response = client.get('/users/123')
        >>> print(response.json())
    """

    def __init__(
        self,
        base_url: str,
        max_retries: int = 3,
        timeout: float = 5.0,
        circuit_breaker: bool = True,
        # Circuit Breaker Settings
        cb_fail_max: int = 5,
        cb_reset_timeout: int = 30,
        # Retry Settings
        retry_wait_min: float = 0.1,
        retry_wait_max: float = 5.0,
    ):
        """
        Initialize the resilient client
        
        Args:
            base_url: Base URL for all requests
            max_retries: Maximum number of retry attempts
            timeout: Request timeout in seconds
            circuit_breaker: Enable circuit breaker
            cb_fail_max: Number of failures before circuit opens
            cb_reset_timeout: Seconds to wait before trying Half-Open
            retry_wait_min: Minimum wait time between retries (seconds)
            retry_wait_max: Maximum wait time between retries (seconds)
        """
        self.base_url = base_url.rstrip('/')
        self.max_retries = max_retries
        self.timeout = timeout
        self.retry_wait_min = retry_wait_min
        self.retry_wait_max = retry_wait_max

        # Initialize metrics
        self.metrics = ClientMetrics()

        # Create session with connection pooling
        self.session = requests.Session()

        # Configure urllib3 retry (for connection errors)
        retries = Urllib3Retry(
            total=0,  # We handle retries manually
            connect=3,  # But retry connection errors
            backoff_factor=0.3,
        )
        adapter = HTTPAdapter(
            max_retries=retries,
            pool_connections=10,
            pool_maxsize=20
        )
        self.session.mount('http://', adapter)
        self.session.mount('https://', adapter)

        # Initialize circuit breaker
        self.circuit_breaker_enabled = circuit_breaker
        if circuit_breaker:
            self.breaker = CircuitBreaker(
                fail_max=cb_fail_max,
                reset_timeout=cb_reset_timeout,
                listeners=[CircuitBreakerListenerImpl()]
            )
        else:
            self.breaker = None

    def get(
        self,
        path: str,
        params: Optional[Dict[str, Any]] = None,
        headers: Optional[Dict[str, str]] = None,
        **kwargs
    ) -> requests.Response:
        """
        Perform a GET request
        
        Args:
            path: API endpoint path
            params: Query parameters
            headers: Request headers
            **kwargs: Additional arguments for requests
            
        Returns:
            requests.Response object
            
        Raises:
            CircuitBreakerError: If circuit breaker is open
            MaxRetriesExceeded: If all retries failed
        """
        return self._request('GET', path, params=params, headers=headers, **kwargs)

    def post(
        self,
        path: str,
        json: Optional[Dict[str, Any]] = None,
        data: Optional[Any] = None,
        headers: Optional[Dict[str, str]] = None,
        **kwargs
    ) -> requests.Response:
        """
        Perform a POST request
        
        Args:
            path: API endpoint path
            json: JSON body
            data: Form data
            headers: Request headers
            **kwargs: Additional arguments for requests
            
        Returns:
            requests.Response object
        """
        return self._request('POST', path, json=json, data=data, headers=headers, **kwargs)

    def put(
        self,
        path: str,
        json: Optional[Dict[str, Any]] = None,
        headers: Optional[Dict[str, str]] = None,
        **kwargs
    ) -> requests.Response:
        """Perform a PUT request"""
        return self._request('PUT', path, json=json, headers=headers, **kwargs)

    def delete(
        self,
        path: str,
        headers: Optional[Dict[str, str]] = None,
        **kwargs
    ) -> requests.Response:
        """Perform a DELETE request"""
        return self._request('DELETE', path, headers=headers, **kwargs)

    def _request(
        self,
        method: str,
        path: str,
        **kwargs
    ) -> requests.Response:
        """
        Internal method to execute HTTP request with circuit breaker and retries
        
        Args:
            method: HTTP method
            path: API endpoint path
            **kwargs: Request arguments
            
        Returns:
            requests.Response object
        """
        self.metrics.total_requests += 1
        url = f"{self.base_url}{path}"

        start_time = time.time()

        try:
            if self.breaker:
                # Execute through circuit breaker
                response = self._execute_with_circuit_breaker(method, url, **kwargs)
            else:
                # Execute without circuit breaker
                response = self._execute_with_retry(method, url, **kwargs)

            duration_ms = (time.time() - start_time) * 1000
            self.metrics.total_duration_ms += duration_ms
            self.metrics.successful_requests += 1

            logger.info(
                f"{method} {path} - {response.status_code} - {duration_ms:.2f}ms"
            )

            return response

        except Exception as e:
            duration_ms = (time.time() - start_time) * 1000
            self.metrics.total_duration_ms += duration_ms
            self.metrics.failed_requests += 1

            logger.error(f"{method} {path} failed: {e}")
            raise

    def _execute_with_circuit_breaker(
        self,
        method: str,
        url: str,
        **kwargs
    ) -> requests.Response:
        """Execute request through circuit breaker"""
        try:
            return self.breaker.call(self._execute_with_retry, method, url, **kwargs)
        except Exception as e:
            if 'open' in str(e).lower():
                self.metrics.circuit_open_count += 1
                raise CircuitBreakerError("Circuit breaker is open") from e
            raise

    def _execute_with_retry(
        self,
        method: str,
        url: str,
        **kwargs
    ) -> requests.Response:
        """Execute request with retry logic"""
        kwargs.setdefault('timeout', self.timeout)

        @retry(
            stop=stop_after_attempt(self.max_retries + 1),
            wait=wait_exponential(
                multiplier=1,
                min=self.retry_wait_min,
                max=self.retry_wait_max
            ),
            retry=retry_if_exception_type((
                requests.exceptions.Timeout,
                requests.exceptions.ConnectionError,
                requests.exceptions.HTTPError
            )),
            before_sleep=before_sleep_log(logger, logging.WARNING),
            reraise=True
        )
        def _make_request():
            response = self.session.request(method, url, **kwargs)
            
            # Raise for 5xx errors (will trigger retry)
            if 500 <= response.status_code < 600:
                self.metrics.retry_count += 1
                response.raise_for_status()
            
            # Don't retry 4xx errors
            if 400 <= response.status_code < 500:
                response.raise_for_status()
            
            return response

        try:
            return _make_request()
        except Exception as e:
            raise MaxRetriesExceeded(f"Max retries exceeded: {e}") from e

    def get_metrics(self) -> Dict[str, Any]:
        """
        Get client metrics
        
        Returns:
            Dictionary containing client metrics
        """
        return {
            'total_requests': self.metrics.total_requests,
            'successful_requests': self.metrics.successful_requests,
            'failed_requests': self.metrics.failed_requests,
            'circuit_open_count': self.metrics.circuit_open_count,
            'retry_count': self.metrics.retry_count,
            'success_rate': self.metrics.success_rate,
            'avg_duration_ms': self.metrics.avg_duration_ms,
        }

    def reset_metrics(self):
        """Reset all metrics to zero"""
        self.metrics = ClientMetrics()

    def __enter__(self):
        """Context manager entry"""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit"""
        self.session.close()
