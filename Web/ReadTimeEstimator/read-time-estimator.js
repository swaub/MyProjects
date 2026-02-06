/**
 * read-time-estimator.js
 * A tiny utility to estimate reading time for blog posts or articles.
 */

const ReadTimeEstimator = {
    /**
     * Calculate reading time
     * @param {string} text - The text to analyze
     * @param {number} wordsPerMinute - Average reading speed (default 200)
     * @returns {object} - { minutes, words, text }
     */
    calculate: function(text, wordsPerMinute = 200) {
        // Strip HTML tags if any
        const cleanText = text.replace(/<\/?[^>]+(>|$)/g, "");
        const trimmedText = cleanText.trim();

        // Handle empty text
        if (!trimmedText) {
             return {
                minutes: 0,
                words: 0,
                formatted: `0 min read`
            };
        }
        
        // Count words
        const words = trimmedText.split(/\s+/).length;
        
        // Calculate minutes
        const minutes = Math.ceil(words / wordsPerMinute);
        
        return {
            minutes: minutes,
            words: words,
            formatted: `${minutes} min read`
        };
    },

    /**
     * Automatically update an element's text with the read time of a target container
     * @param {string} targetSelector - The article/text container
     * @param {string} displaySelector - Where to show the "X min read"
     */
    init: function(targetSelector, displaySelector) {
        const target = document.querySelector(targetSelector);
        const display = document.querySelector(displaySelector);
        
        if (target && display) {
            const stats = this.calculate(target.innerText || target.textContent);
            display.innerText = stats.formatted;
        }
    }
};

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ReadTimeEstimator;
}
