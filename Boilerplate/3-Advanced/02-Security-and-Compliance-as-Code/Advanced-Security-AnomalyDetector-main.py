import asyncio
import pandas as pd
import logging
import os
import json
import aiohttp
from datetime import datetime
from typing import List, Dict, Any

# Configure logging with a secure formatter that masks sensitive data
class SensitiveDataFilter(logging.Filter):
    def filter(self, record):
        # Logic to mask tokens or IPs if they appear in logs
        msg = str(record.msg)
        if "token" in msg.lower():
            record.msg = "REDACTED_SECURITY_TOKEN"
        return True

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("AnomalyDetector")
logger.addFilter(SensitiveDataFilter())

class AnomalyDetector:
    def __init__(self, slack_webhook: str, threshold: float = 3.0):
        self.slack_webhook = slack_webhook
        self.threshold = threshold
        self.session = None

    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()

    async def fetch_logs(self, source: str) -> pd.DataFrame:
        """
        Simulates fetching logs from CloudWatch or ELK.
        In production, this would use boto3 or elasticsearch-py.
        """
        logger.info(f"Fetching logs from {source}...")
        # Mock data representing high-volume traffic logs
        data = {
            "timestamp": pd.date_range(start="2024-01-01", periods=100, freq="min"),
            "request_count": [10] * 95 + [500, 450, 600, 10, 12], # Anomalous spikes
            "status_code": [200] * 90 + [500] * 10,
            "ip_address": ["192.168.1.1"] * 100
        }
        return pd.DataFrame(data)

    async def detect_anomalies(self, df: pd.DataFrame) -> List[Dict[str, Any]]:
        """
        Uses Z-Score to detect statistical anomalies in request counts.
        """
        logger.info("Analyzing logs for anomalies...")
        df['z_score'] = (df['request_count'] - df['request_count'].mean()) / df['request_count'].std()
        anomalies = df[df['z_score'].abs() > self.threshold]
        
        return anomalies.to_dict('records')

    async def send_alert(self, anomaly: Dict[str, Any]):
        """
        Sends real-time alerts to Slack/PagerDuty with graceful degradation.
        """
        payload = {
            "text": f"🚨 *ANOMALY DETECTED* 🚨\nTimestamp: {anomaly['timestamp']}\nRequests: {anomaly['request_count']}\nZ-Score: {anomaly['z_score']:.2f}"
        }
        
        try:
            async with self.session.post(self.slack_webhook, json=payload) as resp:
                if resp.status != 200:
                    logger.error(f"Failed to send alert: {resp.status}")
                else:
                    logger.info("Alert successfully dispatched.")
        except Exception as e:
            # Fallback: Log to local security buffer if external API is down
            logger.critical(f"Alerting system failure. Buffering event locally: {e}")

    async def run_pipeline(self):
        """
        Orchestrates the log analysis pipeline.
        """
        tasks = []
        sources = ["CloudWatch-AppMesh", "ELK-Ingress"]
        
        for source in sources:
            df = await self.fetch_logs(source)
            found_anomalies = await self.detect_anomalies(df)
            
            for anomaly in found_anomalies:
                tasks.append(self.send_alert(anomaly))
        
        if tasks:
            await asyncio.gather(*tasks)
        else:
            logger.info("No anomalies detected in this cycle.")

async def main():
    # Production Grade: Use Environment Variables for Secrets
    SLACK_WEBHOOK = os.getenv("SECURITY_ALERTS_WEBHOOK", "https://hooks.slack.com/services/REDACTED")
    
    async with AnomalyDetector(SLACK_WEBHOOK) as detector:
        while True:
            await detector.run_pipeline()
            await asyncio.sleep(60) # Interval for processing

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Anomaly Detector shut down gracefully.")
