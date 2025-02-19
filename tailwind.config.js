/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./layouts/**/*.html', './content/**/*.{html,md}'],
  darkMode: 'class',
  theme: {
    extend: {},
  },
  plugins: [require("@tailwindcss/typography"), require("daisyui")],
  daisyui: {
    themes: ['emerald', 'forest'],
    darkTheme: 'forest',
  },
}
