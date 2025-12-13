# Data Pipelines for ML

## Overview

Data pipelines for ML handle the extraction, transformation, and loading of data required for machine learning workflows, ensuring data quality, consistency, and availability for training and inference.

## Pipeline Architecture

### ETL vs ELT for ML
```python
# etl_vs_elt.py
class ETLPipeline:
    """Extract, Transform, Load - Traditional approach"""
    def __init__(self):
        self.transformations = []
    
    def extract(self, source):
        return self.read_from_source(source)
    
    def transform(self, data):
        for transformation in self.transformations:
            data = transformation(data)
        return data
    
    def load(self, data, destination):
        self.write_to_destination(data, destination)

class ELTPipeline:
    """Extract, Load, Transform - Modern approach for ML"""
    def __init__(self):
        self.data_lake = DataLake()
    
    def extract_and_load(self, source, raw_location):
        data = self.read_from_source(source)
        self.data_lake.store_raw(data, raw_location)
    
    def transform_on_demand(self, raw_location, transformations):
        raw_data = self.data_lake.read_raw(raw_location)
        return self.apply_transformations(raw_data, transformations)
```

## Data Ingestion

### Batch Ingestion
```python
# batch_ingestion.py
import pandas as pd
from datetime import datetime, timedelta
import boto3

class BatchDataIngestion:
    def __init__(self, s3_bucket):
        self.s3 = boto3.client('s3')
        self.bucket = s3_bucket
    
    def ingest_daily_data(self, source_path, date=None):
        if date is None:
            date = datetime.now().date()
        
        # Read data for specific date
        data = pd.read_csv(f"{source_path}/{date}.csv")
        
        # Add metadata
        data['ingestion_date'] = datetime.now()
        data['source_date'] = date
        
        # Store in data lake with partitioning
        partition_key = f"year={date.year}/month={date.month:02d}/day={date.day:02d}"
        s3_key = f"raw_data/{partition_key}/data.parquet"
        
        # Upload to S3
        data.to_parquet(f"/tmp/{date}.parquet")
        self.s3.upload_file(f"/tmp/{date}.parquet", self.bucket, s3_key)
        
        return s3_key
    
    def ingest_historical_data(self, source_path, start_date, end_date):
        current_date = start_date
        ingested_files = []
        
        while current_date <= end_date:
            try:
                s3_key = self.ingest_daily_data(source_path, current_date)
                ingested_files.append(s3_key)
            except Exception as e:
                print(f"Failed to ingest data for {current_date}: {e}")
            
            current_date += timedelta(days=1)
        
        return ingested_files
```

### Stream Ingestion
```python
# stream_ingestion.py
from kafka import KafkaConsumer, KafkaProducer
import json
import pandas as pd
from datetime import datetime

class StreamDataIngestion:
    def __init__(self, kafka_config):
        self.consumer = KafkaConsumer(
            bootstrap_servers=kafka_config['servers'],
            value_deserializer=lambda x: json.loads(x.decode('utf-8'))
        )
        self.producer = KafkaProducer(
            bootstrap_servers=kafka_config['servers'],
            value_serializer=lambda x: json.dumps(x).encode('utf-8')
        )
        self.buffer = []
        self.buffer_size = 1000
    
    def consume_stream(self, topic, processing_func):
        self.consumer.subscribe([topic])
        
        for message in self.consumer:
            try:
                # Process individual message
                processed_data = processing_func(message.value)
                
                # Add to buffer
                self.buffer.append(processed_data)
                
                # Flush buffer when full
                if len(self.buffer) >= self.buffer_size:
                    self.flush_buffer()
                    
            except Exception as e:
                print(f"Error processing message: {e}")
    
    def flush_buffer(self):
        if self.buffer:
            # Convert to DataFrame and save
            df = pd.DataFrame(self.buffer)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"stream_data_{timestamp}.parquet"
            df.to_parquet(filename)
            
            # Clear buffer
            self.buffer = []
            
            # Optionally send to another topic for further processing
            self.producer.send('processed_data', {'filename': filename, 'records': len(df)})
```

## Data Validation

### Schema Validation
```python
# schema_validation.py
import pandas as pd
from pydantic import BaseModel, ValidationError
from typing import List, Optional
import great_expectations as ge

class DataSchema(BaseModel):
    user_id: int
    timestamp: str
    feature_1: float
    feature_2: Optional[float] = None
    label: Optional[int] = None

class DataValidator:
    def __init__(self, schema_class):
        self.schema_class = schema_class
        self.ge_context = ge.DataContext()
    
    def validate_schema(self, data):
        """Validate data against Pydantic schema"""
        validation_results = {
            'valid_records': [],
            'invalid_records': [],
            'errors': []
        }
        
        for record in data:
            try:
                validated_record = self.schema_class(**record)
                validation_results['valid_records'].append(validated_record.dict())
            except ValidationError as e:
                validation_results['invalid_records'].append(record)
                validation_results['errors'].append(str(e))
        
        return validation_results
    
    def validate_with_great_expectations(self, df, expectation_suite):
        """Validate using Great Expectations"""
        ge_df = ge.from_pandas(df)
        
        # Apply expectation suite
        validation_result = ge_df.validate(expectation_suite=expectation_suite)
        
        return {
            'success': validation_result.success,
            'statistics': validation_result.statistics,
            'results': validation_result.results
        }
    
    def create_expectation_suite(self, df, suite_name):
        """Create expectation suite from sample data"""
        ge_df = ge.from_pandas(df)
        
        # Basic expectations
        for column in df.columns:
            ge_df.expect_column_to_exist(column)
            
            if df[column].dtype in ['int64', 'float64']:
                ge_df.expect_column_values_to_be_between(
                    column,
                    min_value=df[column].min(),
                    max_value=df[column].max()
                )
            
            # Check for null values
            null_percentage = df[column].isnull().sum() / len(df)
            if null_percentage < 0.1:  # Less than 10% nulls
                ge_df.expect_column_values_to_not_be_null(column)
        
        # Save expectation suite
        suite = ge_df.get_expectation_suite()
        self.ge_context.save_expectation_suite(suite, suite_name)
        
        return suite
```

### Data Quality Checks
```python
# data_quality.py
import pandas as pd
import numpy as np
from scipy import stats

class DataQualityChecker:
    def __init__(self, reference_data=None):
        self.reference_data = reference_data
        self.quality_report = {}
    
    def check_completeness(self, df):
        """Check for missing values"""
        missing_stats = {}
        for column in df.columns:
            missing_count = df[column].isnull().sum()
            missing_percentage = (missing_count / len(df)) * 100
            missing_stats[column] = {
                'missing_count': missing_count,
                'missing_percentage': missing_percentage
            }
        
        self.quality_report['completeness'] = missing_stats
        return missing_stats
    
    def check_uniqueness(self, df, unique_columns):
        """Check for duplicate records"""
        uniqueness_stats = {}
        
        # Overall duplicates
        total_duplicates = df.duplicated().sum()
        uniqueness_stats['total_duplicates'] = total_duplicates
        
        # Column-specific uniqueness
        for column in unique_columns:
            if column in df.columns:
                unique_count = df[column].nunique()
                total_count = len(df)
                uniqueness_percentage = (unique_count / total_count) * 100
                
                uniqueness_stats[column] = {
                    'unique_count': unique_count,
                    'total_count': total_count,
                    'uniqueness_percentage': uniqueness_percentage
                }
        
        self.quality_report['uniqueness'] = uniqueness_stats
        return uniqueness_stats
    
    def check_validity(self, df, validation_rules):
        """Check data validity against business rules"""
        validity_stats = {}
        
        for rule_name, rule_func in validation_rules.items():
            try:
                valid_mask = df.apply(rule_func, axis=1)
                valid_count = valid_mask.sum()
                invalid_count = len(df) - valid_count
                validity_percentage = (valid_count / len(df)) * 100
                
                validity_stats[rule_name] = {
                    'valid_count': valid_count,
                    'invalid_count': invalid_count,
                    'validity_percentage': validity_percentage
                }
            except Exception as e:
                validity_stats[rule_name] = {'error': str(e)}
        
        self.quality_report['validity'] = validity_stats
        return validity_stats
    
    def check_consistency(self, df):
        """Check data consistency"""
        consistency_stats = {}
        
        # Check data types consistency
        type_consistency = {}
        for column in df.columns:
            expected_type = df[column].dtype
            actual_types = df[column].apply(type).value_counts()
            type_consistency[column] = {
                'expected_type': str(expected_type),
                'actual_types': actual_types.to_dict()
            }
        
        consistency_stats['type_consistency'] = type_consistency
        
        # Check value ranges for numerical columns
        numerical_columns = df.select_dtypes(include=[np.number]).columns
        range_consistency = {}
        
        for column in numerical_columns:
            q1 = df[column].quantile(0.25)
            q3 = df[column].quantile(0.75)
            iqr = q3 - q1
            lower_bound = q1 - 1.5 * iqr
            upper_bound = q3 + 1.5 * iqr
            
            outliers = df[(df[column] < lower_bound) | (df[column] > upper_bound)]
            
            range_consistency[column] = {
                'outlier_count': len(outliers),
                'outlier_percentage': (len(outliers) / len(df)) * 100,
                'lower_bound': lower_bound,
                'upper_bound': upper_bound
            }
        
        consistency_stats['range_consistency'] = range_consistency
        self.quality_report['consistency'] = consistency_stats
        return consistency_stats
    
    def generate_quality_report(self, df, unique_columns=None, validation_rules=None):
        """Generate comprehensive data quality report"""
        unique_columns = unique_columns or []
        validation_rules = validation_rules or {}
        
        self.check_completeness(df)
        self.check_uniqueness(df, unique_columns)
        self.check_validity(df, validation_rules)
        self.check_consistency(df)
        
        # Overall quality score
        completeness_score = self._calculate_completeness_score()
        uniqueness_score = self._calculate_uniqueness_score()
        validity_score = self._calculate_validity_score()
        consistency_score = self._calculate_consistency_score()
        
        overall_score = np.mean([completeness_score, uniqueness_score, validity_score, consistency_score])
        
        self.quality_report['overall_quality_score'] = overall_score
        
        return self.quality_report
    
    def _calculate_completeness_score(self):
        if 'completeness' not in self.quality_report:
            return 0
        
        missing_percentages = [
            stats['missing_percentage'] 
            for stats in self.quality_report['completeness'].values()
        ]
        avg_missing = np.mean(missing_percentages)
        return max(0, 100 - avg_missing)
    
    def _calculate_uniqueness_score(self):
        if 'uniqueness' not in self.quality_report:
            return 100
        
        # Penalize for duplicates
        total_duplicates = self.quality_report['uniqueness'].get('total_duplicates', 0)
        if total_duplicates == 0:
            return 100
        else:
            return max(0, 100 - (total_duplicates / 100))  # Simplified scoring
    
    def _calculate_validity_score(self):
        if 'validity' not in self.quality_report:
            return 100
        
        validity_percentages = [
            stats.get('validity_percentage', 0)
            for stats in self.quality_report['validity'].values()
            if 'validity_percentage' in stats
        ]
        
        if not validity_percentages:
            return 100
        
        return np.mean(validity_percentages)
    
    def _calculate_consistency_score(self):
        if 'consistency' not in self.quality_report:
            return 100
        
        # Simplified consistency scoring based on outliers
        range_stats = self.quality_report['consistency'].get('range_consistency', {})
        outlier_percentages = [
            stats['outlier_percentage']
            for stats in range_stats.values()
        ]
        
        if not outlier_percentages:
            return 100
        
        avg_outlier_percentage = np.mean(outlier_percentages)
        return max(0, 100 - avg_outlier_percentage)
```

## Feature Engineering Pipeline

### Feature Transformation
```python
# feature_engineering.py
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder, OneHotEncoder
from sklearn.feature_selection import SelectKBest, f_classif

class FeatureEngineeringPipeline:
    def __init__(self):
        self.transformers = {}
        self.feature_selector = None
        self.feature_names = []
    
    def add_temporal_features(self, df, date_column):
        """Add temporal features from datetime column"""
        df[date_column] = pd.to_datetime(df[date_column])
        
        # Extract temporal components
        df[f'{date_column}_year'] = df[date_column].dt.year
        df[f'{date_column}_month'] = df[date_column].dt.month
        df[f'{date_column}_day'] = df[date_column].dt.day
        df[f'{date_column}_dayofweek'] = df[date_column].dt.dayofweek
        df[f'{date_column}_hour'] = df[date_column].dt.hour
        df[f'{date_column}_quarter'] = df[date_column].dt.quarter
        
        # Cyclical encoding for periodic features
        df[f'{date_column}_month_sin'] = np.sin(2 * np.pi * df[f'{date_column}_month'] / 12)
        df[f'{date_column}_month_cos'] = np.cos(2 * np.pi * df[f'{date_column}_month'] / 12)
        df[f'{date_column}_day_sin'] = np.sin(2 * np.pi * df[f'{date_column}_day'] / 31)
        df[f'{date_column}_day_cos'] = np.cos(2 * np.pi * df[f'{date_column}_day'] / 31)
        
        return df
    
    def add_aggregation_features(self, df, group_columns, agg_columns, agg_functions):
        """Add aggregation features"""
        for group_col in group_columns:
            for agg_col in agg_columns:
                for agg_func in agg_functions:
                    feature_name = f'{group_col}_{agg_col}_{agg_func}'
                    
                    if agg_func == 'mean':
                        df[feature_name] = df.groupby(group_col)[agg_col].transform('mean')
                    elif agg_func == 'std':
                        df[feature_name] = df.groupby(group_col)[agg_col].transform('std')
                    elif agg_func == 'count':
                        df[feature_name] = df.groupby(group_col)[agg_col].transform('count')
                    elif agg_func == 'min':
                        df[feature_name] = df.groupby(group_col)[agg_col].transform('min')
                    elif agg_func == 'max':
                        df[feature_name] = df.groupby(group_col)[agg_col].transform('max')
        
        return df
    
    def add_interaction_features(self, df, feature_pairs):
        """Add interaction features"""
        for feat1, feat2 in feature_pairs:
            if feat1 in df.columns and feat2 in df.columns:
                # Multiplication interaction
                df[f'{feat1}_{feat2}_mult'] = df[feat1] * df[feat2]
                
                # Division interaction (with small epsilon to avoid division by zero)
                df[f'{feat1}_{feat2}_div'] = df[feat1] / (df[feat2] + 1e-8)
                
                # Addition interaction
                df[f'{feat1}_{feat2}_add'] = df[feat1] + df[feat2]
                
                # Subtraction interaction
                df[f'{feat1}_{feat2}_sub'] = df[feat1] - df[feat2]
        
        return df
    
    def encode_categorical_features(self, df, categorical_columns, encoding_method='onehot'):
        """Encode categorical features"""
        for column in categorical_columns:
            if column in df.columns:
                if encoding_method == 'onehot':
                    if column not in self.transformers:
                        encoder = OneHotEncoder(sparse=False, handle_unknown='ignore')
                        encoded_features = encoder.fit_transform(df[[column]])
                        self.transformers[column] = encoder
                    else:
                        encoded_features = self.transformers[column].transform(df[[column]])
                    
                    # Create feature names
                    feature_names = [f'{column}_{cat}' for cat in self.transformers[column].categories_[0]]
                    encoded_df = pd.DataFrame(encoded_features, columns=feature_names, index=df.index)
                    
                    # Drop original column and add encoded features
                    df = df.drop(column, axis=1)
                    df = pd.concat([df, encoded_df], axis=1)
                
                elif encoding_method == 'label':
                    if column not in self.transformers:
                        encoder = LabelEncoder()
                        df[column] = encoder.fit_transform(df[column].astype(str))
                        self.transformers[column] = encoder
                    else:
                        df[column] = self.transformers[column].transform(df[column].astype(str))
        
        return df
    
    def scale_numerical_features(self, df, numerical_columns, scaling_method='standard'):
        """Scale numerical features"""
        for column in numerical_columns:
            if column in df.columns:
                if scaling_method == 'standard':
                    if column not in self.transformers:
                        scaler = StandardScaler()
                        df[column] = scaler.fit_transform(df[[column]])
                        self.transformers[column] = scaler
                    else:
                        df[column] = self.transformers[column].transform(df[[column]])
        
        return df
    
    def select_features(self, df, target_column, k=50):
        """Select top k features"""
        X = df.drop(target_column, axis=1)
        y = df[target_column]
        
        if self.feature_selector is None:
            self.feature_selector = SelectKBest(score_func=f_classif, k=k)
            X_selected = self.feature_selector.fit_transform(X, y)
            self.feature_names = X.columns[self.feature_selector.get_support()].tolist()
        else:
            X_selected = self.feature_selector.transform(X)
        
        # Create DataFrame with selected features
        selected_df = pd.DataFrame(X_selected, columns=self.feature_names, index=df.index)
        selected_df[target_column] = y
        
        return selected_df
    
    def transform_pipeline(self, df, config):
        """Apply full feature engineering pipeline"""
        # Make a copy to avoid modifying original data
        df_transformed = df.copy()
        
        # Apply temporal features
        if 'temporal_features' in config:
            for date_col in config['temporal_features']:
                df_transformed = self.add_temporal_features(df_transformed, date_col)
        
        # Apply aggregation features
        if 'aggregation_features' in config:
            agg_config = config['aggregation_features']
            df_transformed = self.add_aggregation_features(
                df_transformed,
                agg_config['group_columns'],
                agg_config['agg_columns'],
                agg_config['agg_functions']
            )
        
        # Apply interaction features
        if 'interaction_features' in config:
            df_transformed = self.add_interaction_features(
                df_transformed,
                config['interaction_features']
            )
        
        # Encode categorical features
        if 'categorical_encoding' in config:
            df_transformed = self.encode_categorical_features(
                df_transformed,
                config['categorical_encoding']['columns'],
                config['categorical_encoding']['method']
            )
        
        # Scale numerical features
        if 'numerical_scaling' in config:
            df_transformed = self.scale_numerical_features(
                df_transformed,
                config['numerical_scaling']['columns'],
                config['numerical_scaling']['method']
            )
        
        # Feature selection
        if 'feature_selection' in config:
            df_transformed = self.select_features(
                df_transformed,
                config['feature_selection']['target_column'],
                config['feature_selection']['k']
            )
        
        return df_transformed
```

## Pipeline Orchestration

### Apache Airflow DAG
```python
# ml_data_pipeline_dag.py
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta
import pandas as pd

default_args = {
    'owner': 'ml-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'ml_data_pipeline',
    default_args=default_args,
    description='ML Data Pipeline',
    schedule_interval='@daily',
    catchup=False,
    max_active_runs=1
)

def extract_data(**context):
    """Extract data from source systems"""
    execution_date = context['execution_date']
    
    # Extract logic here
    data_ingestion = BatchDataIngestion('ml-data-bucket')
    s3_key = data_ingestion.ingest_daily_data('/source/data', execution_date.date())
    
    return s3_key

def validate_data(**context):
    """Validate extracted data"""
    s3_key = context['task_instance'].xcom_pull(task_ids='extract_data')
    
    # Validation logic here
    validator = DataValidator(DataSchema)
    # Load data from S3 and validate
    
    return True

def engineer_features(**context):
    """Engineer features from raw data"""
    s3_key = context['task_instance'].xcom_pull(task_ids='extract_data')
    
    # Feature engineering logic here
    feature_pipeline = FeatureEngineeringPipeline()
    # Process data and save engineered features
    
    return 'processed_features_s3_key'

def quality_check(**context):
    """Perform data quality checks"""
    processed_key = context['task_instance'].xcom_pull(task_ids='engineer_features')
    
    # Quality check logic here
    quality_checker = DataQualityChecker()
    # Load processed data and run quality checks
    
    return True

# Define tasks
extract_task = PythonOperator(
    task_id='extract_data',
    python_callable=extract_data,
    dag=dag
)

validate_task = PythonOperator(
    task_id='validate_data',
    python_callable=validate_data,
    dag=dag
)

feature_task = PythonOperator(
    task_id='engineer_features',
    python_callable=engineer_features,
    dag=dag
)

quality_task = PythonOperator(
    task_id='quality_check',
    python_callable=quality_check,
    dag=dag
)

# Set dependencies
extract_task >> validate_task >> feature_task >> quality_task
```

## Real-time Processing

### Apache Kafka + Spark Streaming
```python
# spark_streaming_pipeline.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

class RealTimeDataPipeline:
    def __init__(self):
        self.spark = SparkSession.builder \
            .appName("MLDataPipeline") \
            .config("spark.sql.streaming.checkpointLocation", "/tmp/checkpoint") \
            .getOrCreate()
    
    def create_kafka_stream(self, kafka_servers, topic):
        """Create Kafka streaming DataFrame"""
        return self.spark \
            .readStream \
            .format("kafka") \
            .option("kafka.bootstrap.servers", kafka_servers) \
            .option("subscribe", topic) \
            .load()
    
    def process_stream(self, stream_df):
        """Process streaming data"""
        # Parse JSON from Kafka
        schema = StructType([
            StructField("user_id", IntegerType()),
            StructField("timestamp", TimestampType()),
            StructField("feature_1", DoubleType()),
            StructField("feature_2", DoubleType())
        ])
        
        parsed_df = stream_df.select(
            from_json(col("value").cast("string"), schema).alias("data")
        ).select("data.*")
        
        # Add processing timestamp
        processed_df = parsed_df.withColumn("processing_time", current_timestamp())
        
        # Apply transformations
        transformed_df = processed_df \
            .withColumn("feature_1_squared", col("feature_1") * col("feature_1")) \
            .withColumn("feature_interaction", col("feature_1") * col("feature_2"))
        
        return transformed_df
    
    def write_to_sink(self, processed_df, output_path):
        """Write processed data to sink"""
        query = processed_df.writeStream \
            .outputMode("append") \
            .format("parquet") \
            .option("path", output_path) \
            .option("checkpointLocation", "/tmp/checkpoint") \
            .trigger(processingTime='10 seconds') \
            .start()
        
        return query
```

## Best Practices

1. **Data Lineage**: Track data flow and transformations
2. **Idempotency**: Ensure pipeline runs are repeatable
3. **Error Handling**: Implement robust error handling and recovery
4. **Monitoring**: Monitor pipeline performance and data quality
5. **Testing**: Test pipelines with sample data
6. **Documentation**: Document data schemas and transformations
7. **Security**: Implement data encryption and access controls
8. **Scalability**: Design for horizontal scaling

## Conclusion

Effective data pipelines are crucial for ML success. They ensure high-quality, consistent data flow from sources to models while maintaining reliability, scalability, and observability throughout the process.