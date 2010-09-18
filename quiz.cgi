#!/usr/local/bin/perl

#***********
# quiz CGI author by kanayan

require 'quiz_view.pl';
require 'quiz_logic.pl';
require 'quiz_cont.pl';

my %ret;
#**********   初期設定ここから   *******************************************

#CGIのURL
$ret{'Url'} = 'http://xxxxx.jp/quiz/quiz.cgi';

#quiz.js ファイルのURL
$ret{'JsUrl'} = 'http://xxxxx.jp/quiz/quiz.js';

#prototype.js ファイルのURL
$ret{'PrototypeUrl'} = 'http://xxxxx.jp/quiz/prototype.js';

#クイズ問題のデータPath
$ret{'QuizData'} = './quiz.dat';

#クイズのランキングのデータPath
$ret{'QuizRankData'} = './quizrank.dat';

#クイズのCssファイルのURL
$ret{'CssUrl'} = 'http://xxxxx.jp/quiz/quiz.css';

#クイズ開始の認証用ファイルPath
$ret{'QuizStartData'} = './quizstart.dat';

#クイズ問題のTitle
$ret{'Title'} = 'Web Quiz';

#CookieのID
$ret{'CookieID'} = 'WebQuiz';

#管理画面のPassWord
$ret{'PassWord'} = '1234';

#**********   初期設定ここまで   ******************************************


my $cont = QuizCont->new(%ret);

print $cont->OutPut;

exit;
