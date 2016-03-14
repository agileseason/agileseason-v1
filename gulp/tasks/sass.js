require('es6-promise').polyfill();
var gulp         = require('gulp');
var browserSync  = require('browser-sync');
var sass         = require('gulp-sass');
var sourcemaps   = require('gulp-sourcemaps');
var handleErrors = require('../util/handleErrors');
var config       = require('../config').sass;
var landing_config       = require('../config').landing_sass;
var autoprefixer = require('gulp-autoprefixer');
var postcss    = require('gulp-postcss');
var concatCss = require('gulp-concat-css');
var postcssFontMagician = require('postcss-font-magician')
var assets  = require('postcss-assets');

gulp.task('sass', ['landing_sass', 'app_sass'], function(){
  console.log('sass completed')
});

gulp.task('app_sass', function () {
  return gulp.src(config.src)
    .pipe(sourcemaps.init())
    .pipe(sass(config.settings))
    .on('error', handleErrors)
    .pipe(autoprefixer({ browsers: ['last 3 version'] }))
    .pipe(postcss([
      assets(),
      postcssFontMagician()
    ]))
    .pipe(concatCss("app.css"))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload({stream:true}));
});

gulp.task('landing_sass', function () {
  return gulp.src(landing_config.src)
    .pipe(sourcemaps.init())
    .pipe(sass(landing_config.settings))
    .on('error', handleErrors)
    .pipe(autoprefixer({ browsers: ['last 3 version'] }))
    .pipe(postcss([
      assets(),
      postcssFontMagician()
    ]))
    .pipe(concatCss("landing_style.css"))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(landing_config.dest))
    .pipe(browserSync.reload({stream:true}));
});
