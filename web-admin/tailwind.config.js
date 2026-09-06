/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        navy: {
          950: '#050814',
          900: '#0B132B',
          850: '#0F1E36',
          800: '#172554',
          700: '#1E3A8A',
          600: '#2563EB',
          500: '#3B82F6',
        },
        greenblack: {
          950: '#03110E',
          900: '#061E18',
          850: '#0A2A22',
          800: '#0F382E',
          700: '#044E3B',
          600: '#0D9488',
          100: '#E6F4EA',
          50: '#F0FDF4',
        },
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

