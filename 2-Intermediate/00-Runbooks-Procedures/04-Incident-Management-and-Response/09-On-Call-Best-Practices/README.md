# On-Call Best Practices

Being on-call is stressful. These practices make it sustainable and effective.

## The On-Call Rotation

### Rotation Frequency
- **Weekly**: Most common, balances burden.
- **Daily**: Too frequent, causes fatigue.
- **Monthly**: Too long, knowledge gaps form.

### Rotation Structure
- **Primary**: First responder.
- **Secondary**: Backup if primary doesn't respond in 5 minutes.
- **Escalation**: Manager or senior engineer for complex issues.

---

## On-Call Readiness

### Before Your Shift
- [ ] Test pager/phone notifications.
- [ ] Review recent incidents and runbooks.
- [ ] Ensure laptop is charged and accessible.
- [ ] Know who your backup is.
- [ ] Review the escalation path.

### During Your Shift
- [ ] Stay within 15 minutes of a computer.
- [ ] Limit alcohol consumption.
- [ ] Keep phone charged and volume on.
- [ ] Acknowledge alerts within 5 minutes.

### Handoff Protocol
Document any ongoing issues or concerns for the next on-call.

---

## The 15-Minute Rule

**If you're stuck for 15 minutes, escalate.**

Pride has no place in incident response. Escalating early:
- Reduces MTTR.
- Prevents burnout.
- Builds team capability.

---

## On-Call Compensation

### Time-Based
- **Stipend**: Fixed payment per on-call shift (e.g., $200/week).
- **Hourly**: Payment for actual hours worked during incidents.

### Time-Off
- **Comp Time**: 1 day off for every week on-call.
- **Flex Time**: Come in late after a late-night page.

### Industry Standards
- **Minimum**: Stipend + comp time.
- **Best**: Stipend + hourly + comp time.

---

## Preventing Burnout

### 1. Limit Frequency
No one should be on-call more than 1 week per month.

### 2. Reduce Toil
Automate routine issues (auto-remediation).

### 3. Improve Alerts
Reduce false positives and noise.

### 4. Provide Support
Never leave on-call alone. Always have a backup.

### 5. Recognize Effort
Thank on-call engineers publicly. Celebrate successful incident responses.

---

## 🏗️ Real-Life Scenario: The "Burned Out" Engineer
**Problem**: An engineer is on-call every other week. They're paged 5 times per night.
**Outcome**: After 3 months, they quit. Exit interview: "I couldn't sleep anymore."
**Fix**: 
- Expand rotation to 8 engineers (on-call once every 2 months).
- Implement auto-remediation for top 5 alert types.
- Add secondary on-call for backup.
**Result**: Pages drop to 1-2 per week. Retention improves.

---

## ❓ Interview Questions
1.  **What is the '15-Minute Rule' for on-call?**
    *   *Answer*: If you're stuck on an incident for 15 minutes without progress, you should escalate to your backup or senior engineer rather than continuing to struggle alone.
2.  **How do you prevent on-call burnout?**
    *   *Answer*: Through fair rotation schedules, reducing toil via automation, improving alert quality, providing adequate compensation, ensuring backup support, and recognizing effort.

---

## 🧠 Quiz Snippet (5/50+)
1.  **What is the most common on-call rotation frequency?** (Weekly)
2.  **True/False: You should handle all incidents alone to prove yourself.** (False - escalate when stuck)
3.  **What is the '15-Minute Rule'?** (Escalate if stuck for 15 minutes)
4.  **Should on-call engineers be compensated?** (Yes)
5.  **What is 'Comp Time'?** (Compensatory time off after on-call duty)
