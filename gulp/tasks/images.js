var changed    = require('gulp-changed');
var gulp       = require('gulp');
var imagemin   = require('gulp-imagemin');
var config     = require('../config').images;
var landing_config     = require('../config').landing_images;
var browserSync  = require('browser-sync');

gulp.task('images', ['landing_images', 'app_images'], function(){
  console.log('images completed')
});

gulp.task('app_images', function() {
  return gulp.src(config.src)
    .pipe(changed(config.dest)) // Ignore unchanged files
    .pipe(imagemin()) // Optimize
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload({stream:true}));
});

gulp.task('landing_images', function() {
  return gulp.src(landing_config.src)
    .pipe(changed(landing_config.dest)) // Ignore unchanged files
    .pipe(imagemin()) // Optimize
    .pipe(gulp.dest(landing_config.dest))
    .pipe(browserSync.reload({stream:true}));
});
