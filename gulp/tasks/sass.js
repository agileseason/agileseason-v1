var gulp         = require('gulp');
var browserSync  = require('browser-sync');
var sass         = require('gulp-sass');
var sourcemaps   = require('gulp-sourcemaps');
var handleErrors = require('../util/handleErrors');
var config       = require('../config').sass;
var autoprefixer = require('gulp-autoprefixer');
var postcss    = require('gulp-postcss');
var concatCss = require('gulp-concat-css');
var postcssFontMagician = require('postcss-font-magician')

gulp.task('sass', function () {
  return gulp.src(config.src)
    .pipe(sourcemaps.init())
    .pipe(sass(config.settings))
    .on('error', handleErrors)
    .pipe(autoprefixer({ browsers: ['last 3 version'] }))
    .pipe(postcss(
      [postcssFontMagician()]
    ))
    .pipe(concatCss("app.css"))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload({stream:true}));
});

// require('es6-promise').polyfill();
// var gulp         = require('gulp');
// var browserSync  = require('browser-sync');
// var sass         = require('gulp-sass');
// var sourcemaps   = require('gulp-sourcemaps');
// var handleErrors = require('../util/handleErrors');
// var config       = require('../config').sass;
// var autoprefixer = require('gulp-autoprefixer');
// var concatCss = require('gulp-concat-css');
// var postcss    = require('gulp-postcss');
// var rucksack = require('gulp-rucksack');
// var postcssFontMagician = require('postcss-font-magician')
// var assets  = require('postcss-assets');

// gulp.task('sass', function () {
  // return gulp.src(config.src)
    // .pipe(sourcemaps.init())
    // .pipe(sass(config.settings))
    // .on('error', handleErrors)
    // .pipe(autoprefixer())
    // .pipe(rucksack())
    // .pipe(postcss(
      // [
        // postcssFontMagician(),
      // ]
    // ))
    // .pipe(concatCss("app.css"))
    // .pipe(sourcemaps.write())
    // .pipe(gulp.dest(config.dest))
    // .pipe(browserSync.reload({stream:true}));
// });
