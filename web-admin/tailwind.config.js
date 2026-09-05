/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        dhatu: {
          teal: '#0F6B6B',
          'teal-dark': '#0B4E4E',
          'teal-light': '#188A8A',
          amber: '#E0A526',
          'amber-dark': '#B88214',
          'amber-light': '#F5BE4E'
        }
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace']
      }
    },
  },
  plugins: [],
}
