# DMI Portfolio Website (Static HTML/CSS)

This repository contains a clean, professional-looking **static portfolio website** used in **DevOps Micro Internship (DMI)** Week 1 to practice:
- Linux basics
- Nginx hosting
- Deployment proof / ownership
- Production-style checks

✅ Students deploy this website on an Ubuntu VM using Nginx and keep it live for 24 hours.

---

## Who is this for?
- DMI students (beginner → intermediate)
- Anyone learning how to host a static site with Nginx on Linux

---

## What you will build
A portfolio-style website hosted on:
- **Ubuntu VM**
- **Nginx**
- Accessible via: `http://<public-ip>`

---

## Mandatory Ownership Proof (DMI Rule)
Before you deploy, you MUST edit the footer and add your details:

Original:

```html
<p>Crafted with <span>cloud</span> excellence by Pravin Mishra</p>
```

Add this line (example):

```html
<p><strong>Deployed by:</strong> DMI Cohort 2 | Rahul Sharma | Group 4 | Week 1 | 16-01-2026</p>
```

✅ This proof must be visible in your browser screenshot submission.

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

