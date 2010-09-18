package QuizLogic;

#*************************************
#	quiz.cgi 用ロジックライブラリ
#*************************************
sub new
{
	my $class = shift;
	my $cont = shift;
	my %ret;
	my @ltime = localtime(time);
	$ret{'Cont'} = $cont;
	$ret{'year'} = $ltime[5] + 1900;
	$ret{'month'} = sprintf("%02d",$ltime[4] + 1);
	$ret{'day'} = sprintf("%02d",$ltime[3]);
	$ret{'hour'} = sprintf("%02d",$ltime[2]);
	$ret{'min'} = sprintf("%02d",$ltime[1]);
	$ret{'sec'} = sprintf("%02d",$ltime[0]);
	$ret{'now'} = $ret{'year'}.$ret{'month'}.$ret{'day'}.$ret{'hour'}.$ret{'min'}.$ret{'sec'};
	return bless{%ret},$class;
}

#*************************************************************
#
#	Rankingデータの削除
#	return :1(ok) 0(異常)
#
#*************************************************************
sub rank_delete_exec
{
	my $class = shift;
	my $cgi = shift;
	if(-f $class->{'Cont'}->{'QuizRankData'})
	{
		open(RANK,"+<".$class->{'Cont'}->{'QuizRankData'}) || return(-1);
		flock(2,RANK);
		my @rank = <RANK>;
		for(my $i=0;$i<@rank;$i++)
		{
			my ($num) = (split(/\t/,$rank[$i]))[0];
			if($$cgi{"delete_$num"} eq 'on')
			{
				$rank[$i] = '';
			}
		}
		seek(RANK,0,0);
		truncate(RANK,tell(RANK));
		print RANK @rank;
		flock(8,RANK);
		close(RANK);
	}
	return(1);
}

#*************************************************************
#
#	クイズのリストを得るためのデータリード関数
#	($list,$max) = quiz_data_read($cgi);
#	return値 :
#	$$list[$i]{'id'}; ID
#	$$list[$i]{'quiz1'}; クイズ1
#	$$list[$i]{'quiz2'}; クイズ2
#	$$list[$i]{'quiz3'}; クイズ3
#	$$list[$i]{'answer'}; 答え番号
#	$$cgi{'page'}; ページ番号
#	$$cgi{'edit_num'}; ID指定(あれば)
#	エラー:-1
#	$max: 最大クイズ数
#*************************************************************
sub quiz_data_read
{
	my $class = shift;
	my $cgi = shift;
	my @list;
	my $max = 0;
	my $page = $$cgi{'page'};
	if($page=~/\D/)
	{
		$page = 0;
	}
	my $edit_num = $$cgi{'edit_num'};
	if(-f $class->{'Cont'}->{'QuizData'})
	{
		open(QUIZ,"<".$class->{'Cont'}->{'QuizData'}) || return(-1);
		flock(1,QUIZ);
		my @data = <QUIZ>;
		flock(8,QUIZ);
		close(QUIZ);
		$max = @data + 0;
		#ID指定なし
		if($edit_num eq '')
		{
			#start を出す
			my $start = $page * 10;
			my $cnt = 0;
			for(my $i=$start;$i<@data;$i++)
			{
				my ($num,$quiz1,$quiz2,$quiz3,$answer,$quiz) = split(/\t/,$data[$i]);
				$list[$cnt]{'id'} = $num;
				$list[$cnt]{'quiz1'} = $quiz1;
				$list[$cnt]{'quiz2'} = $quiz2;
				$list[$cnt]{'quiz3'} = $quiz3;
				$list[$cnt]{'answer'} = $answer;
				$list[$cnt]{'quiz'} = $quiz;
				$cnt++;
				if($cnt >= 10)
				{
					last;
				}
			}
		}else
		{
			for(my $i=$start;$i<@data;$i++)
			{
				my ($num,$quiz1,$quiz2,$quiz3,$answer,$quiz) = split(/\t/,$data[$i]);
				if($num eq $$cgi{'edit_num'})
				{
					$list[0]{'id'} = $num;
					$list[0]{'quiz1'} = $quiz1;
					$list[0]{'quiz2'} = $quiz2;
					$list[0]{'quiz3'} = $quiz3;
					$list[0]{'answer'} = $answer;
					$list[0]{'quiz'} = $quiz;
				}
			}
		}
	}
	return(\@list,$max);
}



#*************************************************************
#
#	クイズ保存処理
#	return値：1(ok) not1(エラー)
#
#**************************************************************
sub quiz_input_save
{
	my $class = shift;
	my $cgi = shift;
	my $quiz = &quiz_not_enter_form_encode($$cgi{'quiz'});
	my $quiz1 = &quiz_not_enter_form_encode($$cgi{'quiz1'});
	my $quiz2 = &quiz_not_enter_form_encode($$cgi{'quiz2'});
	my $quiz3 = &quiz_not_enter_form_encode($$cgi{'quiz3'});
	
	if(-f $class->{'Cont'}->{'QuizData'})
	{
	}else
	{
		open(DAT,">".$class->{'Cont'}->{'QuizData'}) || return(0);
		close(DAT);
		chmod(0666,$class->{'Cont'}->{'QuizData'});
	}
	open(QUIZ,"+<".$class->{'Cont'}->{'QuizData'}) || return(0);
	flock(2,QUIZ);
	my @data = <QUIZ>;
	if($$cgi{'mode'} eq 'input_exec')
	{
		#問題追加
		my $num = (split(/\t/,$data[$#data]))[0] + 1;
		push(@data,"$num\t$quiz1\t$quiz2\t$quiz3\t".$$cgi{'qcheck'}."\t$quiz\t\n");
	}elsif($$cgi{'mode'} eq 'quiz_edit_exec')
	{
		#問題修正
		for(my $i=0;$i<@data;$i++)
		{
			my ($num) = (split(/\t/,$data[$i]))[0];
			if($num eq $$cgi{'edit_num'})
			{
				$data[$i] = "$num\t$quiz1\t$quiz2\t$quiz3\t".$$cgi{'qcheck'}."\t$quiz\t\n";
				last;
			}
		}
	}elsif($$cgi{'mode'} eq 'quiz_delete_exec')
	{
		#問題削除
		for(my $i=0;$i<@data;$i++)
		{
			my ($num) = (split(/\t/,$data[$i]))[0];
			if($$cgi{"delete_$num"} eq 'on')
			{
				$data[$i] = "";
			}
		}
	}
	seek(QUIZ,0,0);
	truncate(QUIZ,tell(QUIZ));
	print QUIZ @data;
	flock(8,QUIZ);
	close(QUIZ);
	return(1);
}
#*************************************************************
#
#	quiz登録時の引数チェック
#	return値 : 1(ok) not1(エラー文字列)
#*************************************************************
sub quiz_input_chk
{
	my $class = shift;
	my $cgi = shift;
	my $error;
	my $quiz_not_count;
	if($$cgi{'quiz1'} eq '')
	{
		$quiz_not_count++;
	}
	if($$cgi{'quiz2'} eq '')
	{
		$quiz_not_count++;
	}
	if($$cgi{'quiz3'} eq '')
	{
		$quiz_not_count++;
	}
	if($quiz_not_count >= 2)
	{
		$error .= '問題選択を二つ以上入力してください。<br>';
	}
	if($$cgi{'quiz'} eq '')
	{
		$error .= '問題を入力してください。<br>';
	}
	if(($$cgi{'qcheck'} eq '1')||($$cgi{'qcheck'} eq '2')||($$cgi{'qcheck'} eq '3'))
	{		
	}else
	{
		$error .= '正答を選択してください。<br>';
	}
	if(
		(($$cgi{'quiz1'} eq '')&&($$cgi{'qcheck'} eq '1'))||
		(($$cgi{'quiz2'} eq '')&&($$cgi{'qcheck'} eq '2'))||
		(($$cgi{'quiz3'} eq '')&&($$cgi{'qcheck'} eq '3'))
	)
	{
		$error .= '選択された正答に答えがありません。';
	}
	if($error)
	{
		return($error);
	}else
	{
		return(1);
	}
}
#*************************************************************
#
#	Loginのチェックを行う
#	return: 0(NG) 1(OK)
#
#*************************************************************
sub login_chk
{
	my $class = shift;
	my $cgi = shift;
	my %cookies;
	my %cookie;
	foreach(split( /; /, $ENV{'HTTP_COOKIE'}))
	{
		my ($cookie_name,$value)=split( /=/ );
		$cookies{$cookie_name} = $value;
	}
	my $password = $cookies{$class->{'Cont'}->{'CookieID'}};
	if($class->{'Cont'}->{'PassWord'} eq $password)
	{
		return(1);
	}else
	{
		return(0);
	}
}

#**************************************************************
#
#	LoginのSet
#	return 1(ok) 0(NG)
#**************************************************************
sub login_set
{
	my $class = shift;
	my $cgi = shift;
	if($$cgi{'InputPass'} eq $class->{'Cont'}->{'PassWord'})
	{
		print "Set-Cookie: $class->{'Cont'}->{'CookieID'}=$$cgi{'InputPass'};Path=/;\n";
	}else
	{
		return(0);
	}
}


#**************************************************************
#
#	Rankingデータをsortして抽出
#	return: ($list(\@listと同じ),問題数,平均回答率,挑戦者数)
#	return: -1(エラー)
#**************************************************************
sub rank_data_read
{
	my $class = shift;
	my $cgi = shift;
	my @list;
	my $ok_average = 0;
	my $count = 0;
	my $rank_size = (stat($class->{'Cont'}->{'QuizRankData'}))[7];
	if((-f $class->{'Cont'}->{'QuizRankData'})&&($rank_size > 0))
	{
		open(RANK,"<".$class->{'Cont'}->{'QuizRankData'}) || return(-1);
		flock(1,RANK);
		my @rank = <RANK>;
		flock(8,RANK);
		close(RANK);
		#まずは回答の速さでsort
		@list = sort{(split(/\t/,$a))[3] <=> (split(/\t/,$b))[3]}@rank;
		#次に正解率でsort
		@list = sort{(split(/\t/,$b))[2] <=> (split(/\t/,$a))[2]}@list;
	
		#回答数
		$count = @rank + 0;
	
		#正答率
		my $all_ok = 0;
		for(my $i=0;$i<@rank;$i++)
		{
			my ($id,$name,$ok_ave,$ok_speed) = split(/\t/,$rank[$i]);
			$all_ok += $ok_ave;
		}
		$ok_average = &round(($all_ok / $count),1);
	}
	#問題数取得
	my $quiz_cnt = 0;
	if(-f $class->{'Cont'}->{'QuizData'})
	{
		open(QDAT,"<".$class->{'Cont'}->{'QuizData'}) || return(-1);
		flock(QDAT,1);
		my $cnt = 0;
		while(my $rec = <QDAT>)
		{
			$quiz_cnt++;
		}
		flock(QDAT,8);
		close(QDAT);
	}
	return(\@list,$quiz_cnt,$ok_average,$count);
}

#*******************************************
#
#	Ranking参加用処理
#	return :0(異常) 1(成功)
#*******************************************
sub rank_start
{
	my $class = shift;
	my $cgi = shift;
	my $mutch = 0;
	my $answer_time;
	my $answer_ok_count;
	open(SDAT,"+<".$class->{'Cont'}->{'QuizStartData'}) || return(0);
	flock(SDAT,2);
	my @sdat = <SDAT>;
	for(my $i=0;$i<@sdat;$i++)
	{
		my ($rid,$time,$ok_count,$taken_time) = (split(/\t/,$sdat[$i]))[0,1,2,4];
		if($rid eq $$cgi{'rid'})
		{
			$mutch = 1;
			$answer_time = $taken_time;
			$answer_ok_count = $ok_count;
			$sdat[$i] = '';
			last;
		}
	}
	
	if($mutch == 0)
	{
		return(0);
	}
	#問題数取得
	my $cnt = 0;
	open(QDAT,"<".$class->{'Cont'}->{'QuizData'}) || return(0);
	flock(QDAT,1);
	my $cnt = 0;
	while(my $rec = <QDAT>)
	{
		$cnt++;
	}
	flock(QDAT,8);
	close(QDAT);
	#正答率算出(四捨五入)
	my $ok_average = &round(($answer_ok_count / $cnt) * 100,1);
	
	#Ranking保存レコード生成
	my $name = &quiz_enter_form_encode($$cgi{'name'});
	if($name eq '')
	{
		#名前なしはエラー
		return(0);
	}
	#一言メッセージ
	my $one_mes = &quiz_enter_form_encode($$cgi{'one_mes'});
	
	#Ranking 保存
	if(-f $class->{'Cont'}->{'QuizRankData'})
	{
	}else
	{
		open(RANK_TMP,">".$class->{'Cont'}->{'QuizRankData'}) || return(0);
		close(RANK_TMP);
		chmod(0666,$class->{'Cont'}->{'QuizRankData'});
	}
	my $save_rec = "$name\t$ok_average\t$answer_time\t$one_mes\t\n";
	open(RANK,"+<".$class->{'Cont'}->{'QuizRankData'}) || return(0);
	flock(2,RANK);
	my @rank = <RANK>;
	my $id = (split(/\t/,$rank[0]))[0] + 1;
	unshift(@rank,$id."\t".$save_rec);
	seek(RANK,0,0);
	truncate(RANK,tell(RANK));
	print RANK @rank;
	flock(8,RANK);
	close(RANK);
	
	#該当認証レコード削除
	seek(SDAT,0,0);
	truncate(SDAT,tell(SDAT));
	print SDAT @sdat;
	flock(SDAT,8);
	close(SDAT);
	
	return(1);
}


#*******************************************
#
#	quiz開始用の認証	
#	return :0(異常) 認証id(成功)
#*******************************************
sub quiz_start_save
{
	my $class = shift;
	my $cgi = shift;
	my $rand = sprintf("%08d",int(rand(10000000)));
	#1週間前のエポック秒
	my $before_week_time = time - (86400 * 7);
	if(-f $class->{'Cont'}->{'QuizStartData'})
	{
		#ファイルを読み取ってユニークのrid生成
		open(DAT,"+<".$class->{'Cont'}->{'QuizStartData'}) || return(0);
		flock(DAT,2);
		my @dat = <DAT>;
		for(my $i=0;$i<@dat;$i++)
		{
			my ($rid,$time,$ok_count) = (split(/\t/,$dat[$i]))[0,1,2];
			if($before_week_time > $time)
			{
				#1週間前ならレコードを消す
				$dat[$i] = '';
				next;
			}
			if($rid eq $rand)
			{
				#IDで同じものがあったら、5回ループし違うIDを生成
				for(my $i=0;$i<5;$i++)
				{
					$rand = sprintf("%08d",int(rand(10000000)));
					if($rid ne $rand)
					{
						last;
					}
				}
				#それでもおなじならエラー
				if($rid eq $rand)
				{
					return(0);
				}
			}
		}
		unshift(@dat,$rand."\t".time."\t"."0\t1\t\n");
		seek(DAT,0,0);
		truncate(DAT,tell(DAT));
		print DAT @dat;
		flock(DAT,8);
		close(DAT);
		chmod(0666,$class->{'Cont'}->{'QuizStartData'});
	}else
	{
		#ファイルが無ければ生成
		open(DAT,">".$class->{'Cont'}->{'QuizStartData'}) || return(0);
		print DAT $rand."\t".time."\t"."0\t1\t\n";
		close(DAT);
		chmod(0666,$class->{'Cont'}->{'QuizStartData'});
	}
	return ($rand);
}

#*******************************************
#
#	クイズの答えあわせ
#	return値：
#	($status,$name,$taken_time,$answer_ave) = $class->quiz_answer_save($cgi);
#	$status：0(異常) 1(正常)
#	$name:回答者
#	$taken_time:かかった時間
#	$answer_ave:正答率
#*******************************************
sub quiz_answer_save
{
	my $class = shift;
	my $cgi = shift;
	my ($taken_time,$average);
	
	#今の回答番号の -1 の値で問題の回答をサーチ
	my $list = &quiz_count_list_get($class,$cgi,-1);
	if($list eq '')
	{
		return();
	}
	my $ok_num = $$list{'answer'};
	
	open(DAT,"+<".$class->{'Cont'}->{'QuizStartData'}) || return(0);
	flock(DAT,2);
	my @dat = <DAT>;
	my $much = 0;
	for(my $i=0;$i<@dat;$i++)
	{
		my ($rid,$time,$ok_count,$quiz_count) = (split(/\t/,$dat[$i]))[0,1,2,3];
		if(($rid eq $$cgi{'rid'})&&($$cgi{'answer_count'} eq $quiz_count))
		{
			$quiz_count++;
			if($$cgi{'ques'} == $ok_num)
			{
				$ok_count++;
			}
			#かかった時間
			$taken_time = time - $time;
			$dat[$i] = "$rid\t$time\t$ok_count\t$quiz_count\t$taken_time\t\n";
			$much = 1;
			#正答率
			$ok_ave = &round(($ok_count / $$cgi{'answer_count'}) * 100,1);
			
			last;
		}
	}
	seek(DAT,0,0);
	truncate(DAT,tell(DAT));
	print DAT @dat;
	flock(DAT,8);
	close(DAT);
	if($much == 0)
	{
		return(0);
	}
	
	return(1,$taken_time,$ok_ave);
}


#*****************************************************
#	クイズ問題リストをreturnする(クイズ番号から。。)
#	$list{'quiz1'} = "クイズ選択1";
#	$list{'quiz2'} = "クイズ選択2";
#	$list{'quiz3'} = "クイズ選択3";
#	$list{'quiz'} = "クイズ問題";
#	$list{'answer'} = "正答番号";
#	エラー時NULL
#*****************************************************
sub quiz_count_list_get
{
	my $class = shift;
	my $cgi = shift;
	my $plus_minus_count = shift;
	my %list;
	my $quiz_count = $$cgi{'answer_count'} + $plus_minus_count;
	$quiz_count=~s/\D//g;
	if($quiz_count eq '')
	{
		#クイズカウントが無ければエラー
		return();
	}
	open(DAT,"<".$class->{'Cont'}->{'QuizData'}) || return();
	flock(DAT,1);
	my $cnt = 0;
	while(my $rec = <DAT>)
	{
		my ($id,$quiz1,$quiz2,$quiz3,$seikai_bangou,$quiz) = (split(/\t/,$rec))[0,1,2,3,4,5];
		if($cnt == $quiz_count)
		{
			$list{'quiz1'} = "$quiz1";
			$list{'quiz2'} = "$quiz2";
			$list{'quiz3'} = "$quiz3";
			$list{'answer'} = $seikai_bangou;
			$list{'quiz'} = $quiz;
			last;
		}
		$cnt++;
	}
	flock(DAT,8);
	close(DAT);
	return(\%list);
}

#form のhidden用encode
sub quiz_form_encode
{
	my $class = shift;
	my $word = shift;
	$word =~s/\"/&quot;/g;
	return($word);
}

#form の保存用encode(改行なし版)
sub quiz_not_enter_form_encode
{
	my $class = shift if(ref($_[0])=~/^QuizLogic/);
	my $word = shift;
	$word =~s/\t/\s/g;
	$word =~s/\r|\n//g;
	return($word);
}

#form の保存用encode(改行版)
sub quiz_enter_form_encode
{
	my $class = shift if(ref($_[0])=~/^QuizLogic/);
	my $word = shift;
	$word =~s/\t/\s/g;
	$word =~s/\r\n|\r|\n/<br>/g;
	return($word);
}

#四捨五入
sub round
{
  my $class = shift if(ref($_[0])=~/^QuizLogic/);
  my ($num, $decimals) = @_;
  my ($format, $magic);
  $format = '%.' . $decimals . 'f';
  $magic = ($num > 0) ? 0.5 : -0.5;
  return sprintf($format, int(($num * (10 ** $decimals)) + $magic) / (10 ** $decimals));
}

1;
