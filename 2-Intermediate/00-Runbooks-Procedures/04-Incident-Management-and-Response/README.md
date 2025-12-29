# 04: Incident Management and Response

An incident is any unplanned interruption to an IT service. How a team responds to an incident defines their operational maturity.

## 👥 Essential Roles

During a major outage (P0/P1), roles must be clearly defined to avoid confusion:

1.  **Incident Commander (IC)**: The leader. They don't touch code. They coordinate, make decisions, and manage the clock.
2.  **Operations Lead**: The "Fixer." They execute the technical changes and communicate technical progress to the IC.
3.  **Communications Lead**: Updates the Status Page and stays in contact with stakeholders/users.
4.  **Scribe**: Records all actions and timelines for the post-mortem.

---

## 📈 Escalation Matrix

When does a "minor glitch" become a "major incident"?

- **P1 (Critical)**: Site is down. Millions of users affected. Financial loss occurring.
- **P2 (High)**: Core feature is broken (e.g., checkout). High user impact.
- **P3 (Medium)**: Non-critical feature broken. Minor user impact.
- **P4 (Low)**: Minor bug. No immediate user impact.

**Escalation Rule**: If the on-call engineer cannot resolve a P1 issue within 15 minutes, the Incident Commander must be paged.

---

## 📝 The Blameless Post-Mortem

The goal is to fix the **system**, not the **person**.

- **Focus on Facts**: What happened? When? Why did it happen (root cause)?
- **Timeline**: A chronological list of actions taken.
- **Action Items**: Concrete steps to ensure the *same* incident never happens again.
- **Culture**: Encourage honesty. If someone made a mistake, thank them for their honesty so the team can learn how to build a guardrail for that mistake.

---

## 🔗 Tools for Response
- **PagerDuty / OpsGenie**: On-call scheduling and alerting.
- **Slack / Microsoft Teams**: Real-time communication (using dedicated #incident-channels).
- **Zoom / Google Meet**: "War Room" for high-severity issues.
