# AWS Messaging (SQS & SNS)

Decoupling applications with Queues and Pub/Sub.

## Architecture: Queue vs Topic
```mermaid
graph TD
    Sender[Producer]
    
    subgraph SQS_Flow [SQS: Point-to-Point]
        Queue[SQS Queue]
        Worker[Consumer Worker]
        Sender --> Queue --> Worker
    end
    
    subgraph SNS_Flow [SNS: Pub/Sub]
        Topic[SNS Topic]
        Sub1[Email]
        Sub2[Lambda]
        Sub3[SQS]
        
        Sender --> Topic
        Topic --> Sub1
        Topic --> Sub2
        Topic --> Sub3
    end
    
    classDef msg fill:#e3f2fd,stroke:#0d47a1
    class SQS_Flow,SNS_Flow msg
```

## Real World Scenarios
### Scenario: Fan-out Pattern
**Context:** When a user buys a product, you need to: 1) Send email receipt, 2) Notify warehouse, 3) Update analytics.
**Solution:**
- **SNS + SQS:** The checkout service publishes ONCE to an SNS Topic.
- **Subscriptions:**
    - SQS Queue for Warehouse Service (Subscribed to Topic)
    - SQS Queue for Analytics Service (Subscribed to Topic)
    - Lambda for Email (Subscribed to Topic)
**Benefit:** Decoupled. You can add more subscribers later (e.g., Rewards Service) without modifying the checkout code.

## Quiz
<details>
<summary><b>1. SQS stands for:</b></summary>
A) Simple Queue Service<br>
B) Simple Query System<br>
C) Standard Queue System<br>
D) Smart Queue Service<br>
<br>
<b>Answer: A) Simple Queue Service</b>
</details>

<details>
<summary><b>2. SNS stands for:</b></summary>
A) Simple Notification Service<br>
B) Simple Name Service<br>
C) Standard Notification System<br>
D) Secure Network Service<br>
<br>
<b>Answer: A) Simple Notification Service</b>
</details>

<details>
<summary><b>3. SQS is strict ordering guaranteed in:</b></summary>
A) FIFO Queues only<br>
B) Standard Queues<br>
C) All queues<br>
D) No queues<br>
<br>
<b>Answer: A) FIFO Queues only</b>
</details>

<details>
<summary><b>4. SQS Standard queues provide:</b></summary>
A) At-least-once delivery (duplicates possible)<br>
B) Exactly-once delivery<br>
C) At-most-once delivery<br>
D) Ordered delivery<br>
<br>
<b>Answer: A) At-least-once delivery (duplicates possible)</b>
</details>

<details>
<summary><b>5. SNS is what type of messaging model?</b></summary>
A) Pub/Sub (Publish-Subscribe)<br>
B) Point-to-Point<br>
C) Queue<br>
D) Database<br>
<br>
<b>Answer: A) Pub/Sub (Publish-Subscribe)</b>
</details>

<details>
<summary><b>6. SQS specific feature to prevent other consumers from adjusting a message while it is being processed:</b></summary>
A) Visibility Timeout<br>
B) Lock<br>
C) Freeze<br>
D) Delete<br>
<br>
<b>Answer: A) Visibility Timeout</b>
</details>

<details>
<summary><b>7. Dead Letter Queue (DLQ) is used for:</b></summary>
A) Messages that failed processing multiple times<br>
B) Deleted messages<br>
C) Letters to santa<br>
D) Fast messages<br>
<br>
<b>Answer: A) Messages that failed processing multiple times</b>
</details>

<details>
<summary><b>8. SQS Short Polling returns:</b></summary>
A) Immediately, even if queue is empty (or has few messages)<br>
B) Waits until messages arrive<br>
C) Never<br>
D) Errors<br>
<br>
<b>Answer: A) Immediately, even if queue is empty (or has few messages)</b>
</details>

<details>
<summary><b>9. SQS Long Polling reduces cost by:</b></summary>
A) Waiting (up to 20s) for a message to arrive before returning an empty response<br>
B) Deleting messages<br>
C) Compressing messages<br>
D) Slowing down<br>
<br>
<b>Answer: A) Waiting (up to 20s) for a message to arrive before returning an empty response</b>
</details>

<details>
<summary><b>10. Can SNS send SMS text messages?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>

<details>
<summary><b>11. Amazon MQ is key when:</b></summary>
A) You need support for industry standard protocols (MQTT, AMQP, STOMP) for legacy migration<br>
B) You want cloud-native SQS<br>
C) You use DynamoDB<br>
D) You hate queues<br>
<br>
<b>Answer: A) You need support for industry standard protocols (MQTT, AMQP, STOMP) for legacy migration</b>
</details>

<details>
<summary><b>12. Max retention period for a message in SQS:</b></summary>
A) 14 days<br>
B) 1 hour<br>
C) 1 year<br>
D) Unlimited<br>
<br>
<b>Answer: A) 14 days</b>
</details>

<details>
<summary><b>13. SNS FIFO Topics enforce:</b></summary>
A) Ordering and deduplication<br>
B) Randomness<br>
C) Duplicates<br>
D) Nothing<br>
<br>
<b>Answer: A) Ordering and deduplication</b>
</details>

<details>
<summary><b>14. Kinesis Data Streams vs SQS:</b></summary>
A) Kinesis = Real-time Big Data streaming (multiple consumers reading same stream). SQS = Job queues (start/finish/delete).<br>
B) They are the same<br>
C) SQS is for big data<br>
D) Kinesis is for emails<br>
<br>
<b>Answer: A) Kinesis = Real-time Big Data streaming (multiple consumers reading same stream). SQS = Job queues (start/finish/delete).</b>
</details>

<details>
<summary><b>15. Message Group ID in FIFO queues is used to:</b></summary>
A) Ensure ordering *within* a specific group (e.g., user_id) while allowing parallel processing across groups<br>
B) Group bills<br>
C) Encrypt data<br>
D) Delete groups<br>
<br>
<b>Answer: A) Ensure ordering *within* a specific group (e.g., user_id) while allowing parallel processing across groups</b>
</details>

<details>
<summary><b>16. SQS allows files larger than 256KB by:</b></summary>
A) Using the SQS Extended Client Library (Storing payload in S3, reference in SQS)<br>
B) It doesn't allow it<br>
C) Compressing it<br>
D) Splitting it manually<br>
<br>
<b>Answer: A) Using the SQS Extended Client Library (Storing payload in S3, reference in SQS)</b>
</details>

<details>
<summary><b>17. Can you subscribe a Lambda function to an SQS queue?</b></summary>
A) Yes, Lambda poller reads from queue and invokes function synchronously<br>
B) No<br>
<br>
<b>Answer: A) Yes, Lambda poller reads from queue and invokes function synchronously</b>
</details>

<details>
<summary><b>18. SNS Message Filtering allows:</b></summary>
A) Subscribers to only receive a subset of messages based on attributes<br>
B) Blocking spam<br>
C) Deleting messages<br>
D) Nothing<br>
<br>
<b>Answer: A) Subscribers to only receive a subset of messages based on attributes</b>
</details>

<details>
<summary><b>19. EventBridge vs SNS:</b></summary>
A) EventBridge is an Event Bus (SaaS integrations, schema registry, content-based routing). SNS is simple Pub/Sub.<br>
B) Same thing<br>
C) SNS is newer<br>
D) EventBridge is strictly for EC2<br>
<br>
<b>Answer: A) EventBridge is an Event Bus (SaaS integrations, schema registry, content-based routing). SNS is simple Pub/Sub.</b>
</details>

<details>
<summary><b>20. What happens if a consumer fails to process an SQS message before visibility timeout expires?</b></summary>
A) The message becomes visible again in the queue for another consumer to retry<br>
B) It is deleted<br>
C) It is archived<br>
D) It crashes<br>
<br>
<b>Answer: A) The message becomes visible again in the queue for another consumer to retry</b>
</details>

<details>
<summary><b>21. Max message size in SQS/SNS (standard)?</b></summary>
A) 256 KB<br>
B) 1 MB<br>
C) 1 GB<br>
D) 64 KB<br>
<br>
<b>Answer: A) 256 KB</b>
</details>
