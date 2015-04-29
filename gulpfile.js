var gulp = require('gulp');
var less = require('gulp-less');
var autoprefixer = require('gulp-autoprefixer');
var minifyCSS = require('gulp-minify-css');
var notify = require('gulp-notify');
var gutil = require('gulp-util');
var watch = require("gulp-watch");
var rename = require("gulp-rename");
var run = require("gulp-run");

gulp.task('less', function () {
  return gulp.src("less/bootstrap.less")
    .pipe(less({compress: true}).on('error', gutil.log))
    .pipe(autoprefixer('last 10 versions', 'ie 9'))
    .pipe(minifyCSS({keepBreaks: false}))
    .pipe(rename('bootstrap.min.css'))
    .pipe(gulp.dest("inst/html_assets/bootstrap/css"));
    // .pipe(notify('Less Compiled, Prefixed and Minified'));
});

gulp.task('render', function () {
  run('rm -rf _ignore/test/test_files/*;Rscript -e "library(packagedocs); library(rmarkdown); render(\'_ignore/test/test.Rmd\', output_format = package_docs());"').exec()
})
// file.copy(\'\', \'bootstrap.min.css\', overwrite = TRUE)

gulp.task('copyboot', function() {
  gulp.src('inst/html_assets/bootstrap/css/bootstrap.min.css')
    .pipe(gulp.dest('_ignore/test/test_files/bootstrap-3.3.2/css/'))
})

gulp.task('copycust', function() {
  gulp.src('inst/html_assets/bootstrap/css/custom.css')
    .pipe(gulp.dest('_ignore/test/test_files/bootstrap-3.3.2/css/'))
})

gulp.task('watch', function() {
  gulp.watch('less/bootstrap.less',
      ['less']);
  gulp.watch('_ignore/test/test.Rmd',
      ['render','copyboot','copycust']);
  gulp.watch('inst/html_assets/bootstrap/css/bootstrap.min.css',
      ['copyboot']);
  gulp.watch('inst/html_assets/bootstrap/css/custom.css',
      ['copycust']);
});

