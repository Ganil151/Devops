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

**1. Who is the absolute authority in a 'Command' channel during an incident?**
- A) The CEO
- B) The Incident Commander (IC)
- C) The fastest typer
- D) The HR Manager

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**2. True/False: The Incident Commander should be the most senior developer on the team.**
- A) False - Any trained SRE can be an IC; it's about coordination, not just seniority.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**3. Which role is responsible for the '30,000-foot view' of the outage?**
- A) Scribe
- B) IC
- C) Ops Lead
- D) Customer Support

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. The 'Ops Lead' reports directly to:**
- A) The Engineers
- B) The IC
- C) Twitter
- D) The Database

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. What is the Scribe's primary tool?**
- A) A hammer
- B) A timestamped log (Slack, Google Doc, etc.)
- C) A debugger
- D) A phone

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. 'Shielding the Engineers' is the primary job of which role?**
- A) IC
- B) Comms Lead
- C) Scribe
- D) Security Lead

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: A good IC asks for 'Technical Updates' every 5-10 minutes.**
- A) True - To keep the timeline moving and catch roadblocks.
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**8. If a VP joins the war room and starts giving orders, what should the IC do?**
- A) Obey immediately
- B) Calmly remind them of the ICS structure and refer them to the Comms Lead
- C) Log out
- D) Cry

<details>
<summary>Show Answer</summary>

**Answer: B** - Maintain the integrity of the command structure.

</details>

**9. 'Role Rotation' prevents:**
- A) Over-specialization and 'Single Point of Failure' (Dave-syndrome)
- B) Fast fixes
- C) Low costs
- D) happiness

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**10. What does the IC do if the Ops Lead suggests a 'High Risk' action?**
- A) Say "Yes" immediately
- B) Ask for the "Verification/Rollback" plan before approving
- C) Do it themselves
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. True/False: The Scribe should record 'Failed' attempts at fixing the issue.**
- A) True - Failures are vital data for the post-mortem.
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**12. The Comms Lead's 'Internal' audience typically includes:**
- A) The site visitors
- B) Executives and Marketing teams
- C) Only other SREs
- D) The ISP

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. A 'Shadow IC' is:**
- A) A secret IC
- B) A junior engineer learning the role by observing a lead IC
- C) A bot
- D) a ghost

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. What occurs when an IC is 'In the weeds'?**
- A) The site gets fixed faster
- B) They lose track of the big picture and fail to coordinate the team
- C) The budget increases
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. Which role is responsible for the 'Status Page'?**
- A) IC
- B) Comms Lead
- C) Scribe
- D) Junior Dev

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: Handover of the IC role should be done during a 'Quiet Period' of the incident.**
- A) True - Never hand over during a critical rollback or migration.
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**17. 'Decision Paralysis' is a risk for which role?**
- A) Scribe
- B) IC
- C) Comms
- D) Support

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. Why have 'Sub-Channels' for Engineers?**
- A) To hide from the IC
- B) To allow technical collaboration without spamming the main 'Command' channel
- C) To use more bandwidth
- D) no reason

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. Which phrase is typical for an IC?**
- A) "I think it's the database."
- B) "Ops Lead, do we have consensus on the rollback path?"
- C) "Let me try to edit this YAML file."
- D) "Who broke this?"

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: The Scribe can also be the Ops Lead.**
- A) False - You cannot do technical work and thorough documentation at the same time.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. 'ICS' was originally adapted from:**
- A) Firefighting and Emergency Response services
- B) Video games
- C) Schools
- D) Libraries

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**22. 'Consensus-based' decision making in ICS means:**
- A) Everyone votes
- B) The IC listens to experts (Leads) then makes a firm decision
- C) No decisions are made
- D) checking Twitter

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. Which role verifies that 'Rollback' steps are prepared?**
- A) Scribe
- B) IC (by asking the Ops Lead)
- C) Marketing
- D) The Customer

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. The 'Strategic Phase' of an incident is managed by:**
- A) The Ops Lead
- B) The IC
- C) The intern
- D) the cloud provider

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. A successful IC creates a feeling of _____ and _____ in the war room.**
- A) Fear and Panic
- B) Calm and Order
- C) Confusion and Speed
- D) Boredom and Noise

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
