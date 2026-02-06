# ReadTimeEstimator.js

A lightweight (1KB), zero-dependency JavaScript library to calculate reading time for articles and blog posts.

## 🚀 Quick Start

1.  Include the script in your HTML:
    ```html
    <script src="read-time-estimator.js"></script>
    ```

2.  Initialize it with your content selectors:
    ```javascript
    // Selects text from #article and displays time in #time-display
    ReadTimeEstimator.init('#article', '#time-display');
    ```

## 🎮 Demo
Open `demo.html` in your browser to see it in action.

## ⚙️ Advanced Usage
You can also use the raw calculation method:

```javascript
const stats = ReadTimeEstimator.calculate("Your long text here...", 200); // 200 WPM
console.log(stats.minutes);   // e.g., 5
console.log(stats.formatted); // "5 min read"
```
