/* Notes:
   - gulp/tasks/browserSync.js watches and reloads compiled files
*/

var gulp   = require('gulp');
var config = require('../config');
var watch  = require('gulp-watch');

gulp.task('watch', ['browserSync'], function(callback) {
  watch(config.sass.src, function() { gulp.start('sass'); });
  watch(config.landing_sass.src, function() { gulp.start('landing_sass'); });
  watch(config.landing_images.src, function() { gulp.start('landing_images'); });
  watch(config.images.src, function() { gulp.start('images'); });
  // Watchify will watch and recompile our JS, so no need to gulp.watch it
});
