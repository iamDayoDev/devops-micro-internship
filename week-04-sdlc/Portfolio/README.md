## Week 4: Software Development Life Cycle (SDLC) & Deployment

This week, I focused on enhancing the footer of my portfolio website and implementing a dynamic deployment date feature. I also polished the UI for better readability and accessibility.

This is part of the DevOps Micro-Internship program, where I am learning about the software development life cycle and deployment processes. In this week, I completed the following tasks:

1. Created a Jira Account and Set Up My Professional Profile

2. Created an Epic in Jira

3. Created a Space (Project) in Jira and Added Issues
 - S1 — Update site header text
 - S2 — Primary button color refresh
 - S3 — Improve hero subtitle copy
 - S4 — Footer with version & date
 - S5 — Add “Contact / About” section
 - S6 — Add “Join DMI” call-to-action

4. Added Subtask to S1 & S4 of the Issues in Jira

5. I added Descriptions, Acceptance Criteria, Labels and Story Points to the Issues in Jira

6. Created a Sprint in Jira, Added Issues to the Sprint and Started the Sprint

6. Completed the Issues in the Sprint and Closed the Sprint

7. Use Filters to View Stories + Subtasks + Status

8. Open Burndown Report (for later tracking)

### Assignment 3: Run a 5-Day Mini-Sprint in Jira and Ship an Increment

1. Create a Story in Jira

2. Define Sprint Goal
Write a clear sprint goal that describes the value you will deliver by the end of the sprint.

3. Created Subtasks Under the Story
Create 5 subtasks (one per day). Use these titles exactly:

- Day 1 — Implement footer & deploy

- Day 2 — Make deploy date dynamic

- Day 3 — Polish & accessibility

- Day 4 — Provenance / health signal

- Day 5 — Demo + retro + burndown

### Task 1 — Setup Sprint in Jira (Sprint 1) and Start It

- Goal: Put the story into Sprint 1, define sprint goal, and start sprint.

```
Notes:

Open your Jira project for Pravin Mishra Portfolio Website – <YourName>

Go to Backlog → Create sprint → Sprint 1

Add your story to Sprint 1

Set Sprint Goal (paste from above)

Click Start sprint

```
### Task 2 — Day 1: Implement Footer + Commit + Deploy to EC2

- Goal: Add footer text to the website and make it visible on EC2.

Notes:

Clone the portfolio template repo (or use your existing local clone):

git clone https://github.com/pravinmishraaws/Pravin-Mishra-Portfolio-Template.git
cd Pravin-Mishra-Portfolio-Template
Create a feature branch:

```
git branch feature/footer-v1
git switch feature/footer-v1
```
- Add footer to the website:

- Locate the footer section in the template (often index.html and other pages)

Add this text (replace <Student Name> with your name):
Pravin Mishra Portfolio v1.0 — Deployed on <DD Mon YYYY> — By <Student Name>

- Move subtask Day 1 → In Progress → Done

- Add Daily Scrum comment to the Story


## Task 3 — Day 2: Make Deploy Date Dynamic 

## Dynamic Deployment Date Feature

I have also added a dynamic deployment date feature to the footer. You can customize it as follows:

```html
<script>
        document.addEventListener("DOMContentLoaded", () => {
            const dateElement = document.getElementById("deployDate");
            const now = new Date();

            const options = { day: '2-digit', month: 'short', year: 'numeric' };
            let formattedDate = new Intl.DateTimeFormat('en-GB', options).format(now);
            
            // Ensures format is "03 Feb 2026"
            dateElement.textContent = formattedDate.replace(',', '');
        });
    </script>
```
## How It Works:
- The script waits for the DOM to load.
- It fetches the current date and formats it to "DD MMM YYYY".
- The formatted date is inserted into the `<span id="deployDate"></span>` in the footer.


## Task 4 — Day 3: Polish & Accessibility

### Footer UI Improvements

I refined the footer to improve readability, spacing, and overall accessibility across desktop and mobile devices.

### Typography & Contrast

- Increased base font size to improve readability.

- Adjusted text color from light gray to higher-contrast gray for better visibility on dark backgrounds.

- Reduced visual dominance of footer metadata text.


### Spacing & Layout

- Reduced excessive top padding in the footer.

- Normalized margins between headings, lists, and sections.

- Improved vertical rhythm for cleaner visual flow.


### Footer Bottom Section

- Reduced font size to match its informational role.

- Increased spacing between elements.

- Improved contrast consistency.


### Responsive Design Enhancements

- Optimized padding and gaps for smaller screens.

- Ensured footer grid stacks correctly on mobile.

- Increased social icon sizes to meet minimum tap target guidelines.


### Validation

- Tested on desktop at normal width.

- Tested on mobile using browser DevTools with narrow viewport.

### Result

- Footer renders cleanly and consistently across screen sizes.

- Improved usability, readability, and accessibility.

