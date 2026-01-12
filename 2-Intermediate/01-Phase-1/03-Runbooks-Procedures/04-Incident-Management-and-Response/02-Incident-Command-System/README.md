---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Too Many Cooks" War Room
**Problem**: During a P0 site-wide outage, 25 engineers joined the Zoom war room. Everyone started shouting technical suggestions at once. Three different engineers tried to restart three different databases simultaneously without informing anyone else.
**Crisis**: The conflicting database restarts caused a "Split-Brain" scenario, corrupting 4 hours of user data.
**Outcome**: The outage lasted 8 hours instead of 30 minutes.
**Solution**: Formally implemented the **ICS (Incident Command System)**. For the next outage, only the "Incident Commander" (IC) was allowed to speak globally. Engineers worked in sub-channels under the "Ops Lead."
**Result**: The war room was silent except for coordination calls. MTTR dropped to 20 minutes for the next major event.

### Scenario 2: The Executive Interference
**Problem**: During a sensitive data breach incident, the CEO and VP of Marketing kept direct-messaging the lead engineer, asking "When will it be fixed?" and "What should we say on Twitter?"
**Crisis**: The lead engineer spent 40% of their time answering DMs instead of stopping the data leak.
**Outcome**: The breach stayed open 30 minutes longer than necessary.
**Solution**: Designated a highly organized Project Manager as the **Communications Lead (Comms)**. All executives were told to talk ONLY to the Comms lead.
**Result**: The engineers were shielded from "noise," allowing them to focus 100% on the technical fix.

### Scenario 3: The "Memory Hole" Post-Mortem
**Problem**: A company had a successful incident mitigation, but during the post-mortem, no one could remember the exact order of events. "Did we scale UP before or after we flushed the cache?"
**Root Cause**: Everyone was busy fixing things, and no one was taking notes.
**Outcome**: The post-mortem was useless for preventing future errors because the timeline was full of "I think so" and "maybe."
**Solution**: Mandated the **Scribe** role for every P1/P2 incident. The Scribe used a specific Slack bot to timestamp every major command and decision.
**Result**: Post-mortems now have a 100% accurate "Black Box" recording of the incident, leading to much better long-term fixes.

---

## ❓ Interview Questions

1.  **Explain why the Incident Commander (IC) should not touch code or logs.**
    - *Answer*: If the IC is "in the weeds" with technical details, they lose their **situational awareness**. They might miss the fact that the blast radius is growing or that a secondary system is failing. Their job is to manage the *team* and the *response*, not the *code*.
2.  **What is the 'Ops Lead' responsible for in a mature ICS structure?**
    - *Answer*: The Ops Lead is the "Field General." They manage the technical specialists (DBAs, Network devs, etc.) and translate the IC's strategic goals (e.g., "Restore service to US-West") into specific technical tasks.
3.  **How does the 'Comms Lead' assist the technical team during a crisis?**
    - *Answer*: By acting as a **Shield**. They handle the status page updates, Slack announcements, and direct-messaging stakeholders. This allows the technical team to work without the distraction of constant status requests.
4.  **Why is the Scribe role critical for compliance and learning?**
    - *Answer*: The Scribe provides a legally and operationally defensible **Timeline of Events**. For compliance (like SOC2 or HIPAA), proving what was done and when is mandatory. For learning, it shows exactly where bottlenecks occurred.
5.  **What criteria do you use to 'Hand over' the IC role during a long outage?**
    - *Answer*: A handover should happen every 4-8 hours to prevent fatigue. The new IC must be fully briefed on: 1. Current Status. 2. Actions taken so far. 3. Current Hypothesis. 4. Risks being monitored.
6.  **Can a junior engineer be an Incident Commander?**
    - *Answer*: Yes, and they *should* be. In many SRE cultures, being an IC is about process management, not seniority. With a "Shadow IC" program, juniors can learn to manage high-pressure situations, which is a key growth path in SRE.

---

## 🧠 Comprehensive Quiz (25 Questions)

<b>1. Who is the absolute authority in a 'Command' channel during an incident?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>2. True/False: The Incident Commander should be the most senior developer on the team.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>3. Which role is responsible for the '30,000-foot view' of the outage?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. The 'Ops Lead' reports directly to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. What is the Scribe's primary tool?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>6. 'Shielding the Engineers' is the primary job of which role?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. True/False: A good IC asks for 'Technical Updates' every 5-10 minutes.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>8. If a VP joins the war room and starts giving orders, what should the IC do?</b>
<details>
<summary>Show Answer</summary>
Answer: B** - Maintain the integrity of the command structure.
</details>


<b>9. 'Role Rotation' prevents:</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>10. What does the IC do if the Ops Lead suggests a 'High Risk' action?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. True/False: The Scribe should record 'Failed' attempts at fixing the issue.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>12. The Comms Lead's 'Internal' audience typically includes:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>13. A 'Shadow IC' is:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. What occurs when an IC is 'In the weeds'?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. Which role is responsible for the 'Status Page'?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. True/False: Handover of the IC role should be done during a 'Quiet Period' of the incident.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>17. 'Decision Paralysis' is a risk for which role?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. Why have 'Sub-Channels' for Engineers?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. Which phrase is typical for an IC?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. True/False: The Scribe can also be the Ops Lead.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>21. 'ICS' was originally adapted from:</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>22. 'Consensus-based' decision making in ICS means:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>23. Which role verifies that 'Rollback' steps are prepared?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>24. The 'Strategic Phase' of an incident is managed by:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>25. A successful IC creates a feeling of _____ and _____ in the war room.</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>
