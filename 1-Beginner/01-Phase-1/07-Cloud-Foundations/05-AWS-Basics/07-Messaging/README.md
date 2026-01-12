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

<b>1. SQS stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Simple Queue Service</b>
</details>


<b>2. SNS stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Simple Notification Service</b>
</details>


<b>3. SQS is strict ordering guaranteed in:</b>
<details>
<summary>Show Answer</summary>
Answer: A) FIFO Queues only</b>
</details>


<b>4. SQS Standard queues provide:</b>
<details>
<summary>Show Answer</summary>
Answer: A) At-least-once delivery (duplicates possible)</b>
</details>


<b>5. SNS is what type of messaging model?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Pub/Sub (Publish-Subscribe)</b>
</details>


<b>6. SQS specific feature to prevent other consumers from adjusting a message while it is being processed:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Visibility Timeout</b>
</details>


<b>7. Dead Letter Queue (DLQ) is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Messages that failed processing multiple times</b>
</details>


<b>8. SQS Short Polling returns:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Immediately, even if queue is empty (or has few messages)</b>
</details>


<b>9. SQS Long Polling reduces cost by:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Waiting (up to 20s) for a message to arrive before returning an empty response</b>
</details>


<b>10. Can SNS send SMS text messages?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>11. Amazon MQ is key when:</b>
<details>
<summary>Show Answer</summary>
Answer: A) You need support for industry standard protocols (MQTT, AMQP, STOMP) for legacy migration</b>
</details>


<b>12. Max retention period for a message in SQS:</b>
<details>
<summary>Show Answer</summary>
Answer: A) 14 days</b>
</details>


<b>13. SNS FIFO Topics enforce:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Ordering and deduplication</b>
</details>


<b>14. Kinesis Data Streams vs SQS:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Kinesis = Real-time Big Data streaming (multiple consumers reading same stream). SQS = Job queues (start/finish/delete).</b>
</details>


<b>15. Message Group ID in FIFO queues is used to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Ensure ordering *within* a specific group (e.g., user_id) while allowing parallel processing across groups</b>
</details>


<b>16. SQS allows files larger than 256KB by:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Using the SQS Extended Client Library (Storing payload in S3, reference in SQS)</b>
</details>


<b>17. Can you subscribe a Lambda function to an SQS queue?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, Lambda poller reads from queue and invokes function synchronously</b>
</details>


<b>18. SNS Message Filtering allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Subscribers to only receive a subset of messages based on attributes</b>
</details>


<b>19. EventBridge vs SNS:</b>
<details>
<summary>Show Answer</summary>
Answer: A) EventBridge is an Event Bus (SaaS integrations, schema registry, content-based routing). SNS is simple Pub/Sub.</b>
</details>


<b>20. What happens if a consumer fails to process an SQS message before visibility timeout expires?</b>
<details>
<summary>Show Answer</summary>
Answer: A) The message becomes visible again in the queue for another consumer to retry</b>
</details>


<b>21. Max message size in SQS/SNS (standard)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 256 KB</b>
</details>
