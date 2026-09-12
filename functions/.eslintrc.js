module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
  ],
  rules: {
    'quotes': ['off'],
    'semi': ['off'],
    'indent': ['off'],
    'max-len': ['off'],
    'object-curly-spacing': ['off'],
    'comma-dangle': ['off'],
    'padded-blocks': ['off'],
    'no-var': ['off'],
    'quote-props': ['off'],
    'require-jsdoc': ['off'],
    'no-unused-vars': ['warn'],
    'prefer-arrow-callback': ['off'],
    'space-before-blocks': ['off'],
    'eol-last': ['off'],
  },
  parserOptions: {
    ecmaVersion: 2020,
  },
};