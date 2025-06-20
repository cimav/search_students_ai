module.exports = {
    content: [
        './app/views/**/*.{html,erb,haml,slim}',
        './app/helpers/**/*.rb',
        './app/frontend/**/*.{js,jsx}',
        './app/javascript/**/*.{js,jsx}'
    ],
    theme: {
        extend: {},
    },
    plugins: [
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography')
    ],
}
