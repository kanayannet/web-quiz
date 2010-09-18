package QuizView;

#*****************************
# quiz.cgi 用 viewライブラリ
#*****************************

sub new
{
	my $class = shift;
	my $cont = shift;
	my $logic = shift;
	my %ret;
	$ret{'Cont'} = $cont;
	$ret{'Logic'} = $logic;
	return bless{%ret},$class;
}

sub TopPage
{
	my $class = shift;
	my $print = &head($class);
	#正解率や上位入賞者を出す
	my ($list,$quiz_cnt,$ok_average,$charange_count) = $class->{'Logic'}->rank_data_read();
	if($list < 0)
	{
		&error($class,'ランキングデータが正常に読み込めませんでした。');
	}
	my $name1 = &tag_convert((split(/\t/,$$list[0]))[1]);
	my $ok_ave1 = (split(/\t/,$$list[0]))[2];
	my $sec1 = (split(/\t/,$$list[0]))[3];
	#分換算
	my $min1 = int($sec1 / 60);
	$sec1 = int($sec1 % 60);
	my $name2 = &tag_convert((split(/\t/,$$list[1]))[1]);
	my $ok_ave2 = (split(/\t/,$$list[1]))[2];
	my $sec2 = (split(/\t/,$$list[1]))[3];
	#分換算
	my $min2 = int($sec2 / 60);
	$sec2 = int($sec2 % 60);
	my $name3 = &tag_convert((split(/\t/,$$list[2]))[1]);
	my $ok_ave3 = (split(/\t/,$$list[2]))[2];
	my $sec3 = (split(/\t/,$$list[2]))[3];
	#分換算
	my $min3 = int($sec3 / 60);
	$sec3 = int($sec3 % 60);
	$print .= <<"__END";
<br>
<div id=title>
$class->{'Cont'}->{'Title'}
</div>
<br><br>
<form action="$class->{'Cont'}->{'Url'}" method="POST">
<div id=quiz_start>
<br>
<input type="hidden" name="mode" value="quiz_start">
お名前：&nbsp;<input type="text" name="name" size="20" maxlength="10">
&nbsp;<input type="submit" value="問題を解く">
<br>&nbsp;
</div>
</form><br><br>
<table id=answer_status>
<tr>
<td id=answer_status_main_td>
正答率：$ok_average\%
</td>
<td id=answer_status_main_td>
問題数：$quiz_cnt問
</td>
<td id=answer_status_main_td>
挑戦者：$charange_count人
</td>
</tr>
<tr>
<td id=answer_status_rank1_td colspan=3>
1位：　$name1　　$min1分$sec1秒　　正答率：$ok_ave1\%
</td>
</tr>
<tr>
<td id=answer_status_rank2_td colspan=3>
2位：　$name2　　$min2分$sec2秒　　正答率：$ok_ave2\%
</td>
</tr>
<tr>
<td id=answer_status_rank3_td colspan=3>
3位：　$name3　　$min3分$sec3秒　　正答率：$ok_ave3\%
</td>
</tr>
<tr>
<td id=answer_status_rank3_td colspan=3>
<a href="$class->{'Cont'}->{'Url'}?mode=rank_list">続き...</a>
</td>
</tr>
</table>
<br>
<div id=kanri_link>
<a href="$class->{'Cont'}->{'Url'}?mode=mente_top">管理画面</a>
</div>
__END
	$print .= &foot($class);
	return $print;
}

#RankingList画面
sub rank_list
{
	my $class = shift;
	my $cgi = shift;
	
	#Ranking一覧
	my ($list,$quiz_cnt,$ok_average,$charange_count) = $class->{'Logic'}->rank_data_read();
	#Page 整理
	my $max = @$list + 0;
	my $page = $$cgi{'page'};
	if($page=~/\D/)
	{
		$page = 0;
	}
	#start を出す
	my $start = $page * 10;
	my $page_max = $max / 10;
	if($page_max=~/\./)
	{
		$page_max = int($page_max);
		$page_max++;
	}
	my $cnt = 0;
	for(my $i=0;$i<$page_max;$i++)
	{
		$cnt++;
		my $link;
		if($i == $$cgi{'page'})
		{
			$link = qq|$cnt|;
		}else
		{
			$link = qq|<a href="$class->{'Cont'}->{'Url'}?mode=rank_list&page=$i">$cnt</a>|;
		}
		 $page_html .= qq|$link \||;
	}
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
Ranking
</div>
<br>
__END
	$cnt = 0;
	for(my $i=$start;$i<@$list;$i++)
	{
		my ($id,$name,$ok_average,$answer_time,$one_mes) = split(/\t/,$$list[$i]);
		$name = &tag_convert($name);
		$one_mes = &tag_br_convert($one_mes);
		#分換算
		my $min = int($answer_time / 60);
		my $sec = int($answer_time % 60);
		my $rank = $i + 1;
		if($rank == 1)
		{
			$print .=<<"__END";
			<div id=rank1_list>
			<div id=rank1_title>順位：$rank位　　$min分$sec秒　　正答率：$ok_average\%</div>
			<div id=rank1_name>
			お名前：$name
			</div>
			<div id=rank1_text>
			$one_mes
			</div>
			</div><br>

__END
		}else
		{
			$print .=<<"__END";
			<div id=rank_list>
			<div id=rank_title>順位：$rank位　　$min分$sec秒　　正答率：$ok_average\%</div>
			<div id=rank_name>
			お名前：$name
			</div>
			<div id=rank_text>
			$one_mes
			</div>
			</div><br>

__END
		}
		$cnt++;
		if($cnt >= 10)
		{
			last;
		}
	}
	$print .=<<"__END";
<br>
<div id="page_list">$page_html</div>
<br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}

#Ranking削除完了画面
sub rank_delete_finish
{
	my $class = shift;
	my $cgi = shift;
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
管理画面
</div>
<br>
<div id="mente_menu">
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=mente_top">問題の登録</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit">問題の修正・削除</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=rank_edit">ランキング管理</a>
</div>
</div>
<div style="clear:both;"></div><br><br>
ランキング削除が完了しました。
<br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}

#Ranking一覧画面
sub rank_edit
{
	my $class = shift;
	my $cgi = shift;
	
	#Ranking一覧
	my ($list,$quiz_cnt,$ok_average,$charange_count) = $class->{'Logic'}->rank_data_read();
	#Page 整理
	my $max = @$list + 0;
	my $page = $$cgi{'page'};
	if($page=~/\D/)
	{
		$page = 0;
	}
	#start を出す
	my $start = $page * 10;
	my $page_max = $max / 10;
	if($page_max=~/\./)
	{
		$page_max = int($page_max);
		$page_max++;
	}
	my $cnt = 0;
	for(my $i=0;$i<$page_max;$i++)
	{
		$cnt++;
		my $link;
		if($i == $$cgi{'page'})
		{
			$link = qq|$cnt|;
		}else
		{
			$link = qq|<a href="$class->{'Cont'}->{'Url'}?mode=rank_edit&page=$i">$cnt</a>|;
		}
		 $page_html .= qq|$link \||;
	}
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
管理画面
</div>
<br>
<div id="mente_menu">
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=mente_top">問題の登録</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit">問題の修正・削除</a>
</div>
<div id="mente_menu_in">
ランキング管理
</div>
</div>
<div style="clear:both;"></div><br>
<div id="page_list">$page_html</div>
<br>
<form action="$class->{'Cont'}->{'Url'}" method="POST" name="nform">
<input type="hidden" name="mode" value="rank_delete_exec">
<input type="button" value="チェックしたランキングを削除" onclick="rank_delete_exec();">
<br><br>
__END
	
	$cnt = 0;
	for(my $i=$start;$i<@$list;$i++)
	{
		my ($id,$name,$ok_average,$answer_time,$one_mes) = split(/\t/,$$list[$i]);
		$name = &tag_convert($name);
		$one_mes = &tag_br_convert($one_mes);
		my $rank = $i + 1;
		$print .=<<"__END";
		<div id=loglist>
		<div id=logtitle>順位：$rank位</div>
		<div id=logedit>
		&nbsp;
		<input type=checkbox name="delete_$id" value="on">
		</div>
		<div id=logtext>
		お名前：$name
		<br><br>
		$one_mes
		</div>
		</div><br>
__END
		$cnt++;
		if($cnt >= 10)
		{
			last;
		}
	}
	$print .=<<"__END";
<br>
<input type="button" value="チェックしたランキングを削除" onclick="rank_delete_exec();">
</form>
<div id="page_list">$page_html</div>
<br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}

#問題削除完了画面
sub delete_finish
{
	my $class = shift;
	my $cgi = shift;
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
管理画面
</div>
<br>
<div id="mente_menu">
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=mente_top">問題の登録</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit">問題の修正・削除</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=rank_edit">ランキング管理</a>
</div>
</div>
<div style="clear:both;"></div><br><br>
問題削除が完了しました。
<br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}
#問題修正完了画面
sub edit_finish
{
	my $class = shift;
	my $cgi = shift;
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
管理画面
</div>
<br>
<div id="mente_menu">
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=mente_top">問題の登録</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit">問題の修正・削除</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=rank_edit">ランキング管理</a>
</div>
</div>
<div style="clear:both;"></div><br><br>
問題修正が完了しました。
<br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}

#修正入力画面
sub quiz_edit_view
{
	my $class = shift;
	my $cgi = shift;
	my ($list,$max) = $class->{'Logic'}->quiz_data_read($cgi);
	if(!@$list)
	{
		&error($class,'該当のクイズは既に削除されているか、見つかりませんでした。');
	}
	my $id = $$list[0]{'id'};
	my $quiz = &tag_convert($$list[0]{'quiz'});
	my $quiz1 = &tag_convert($$list[0]{'quiz1'});
	my $quiz2 = &tag_convert($$list[0]{'quiz2'});
	my $quiz3 = &tag_convert($$list[0]{'quiz3'});
	my $answer_1 = 'checked' if($$list[0]{'answer'} == 1);
	my $answer_2 = 'checked' if($$list[0]{'answer'} == 2);
	my $answer_3 = 'checked' if($$list[0]{'answer'} == 3);
	
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
管理画面
</div>
<br>
<div id="mente_menu">
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=mente_top">問題の登録</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit">問題の修正・削除</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=rank_edit">ランキング管理</a>
</div>
</div>
<div style="clear:both;"></div><br><br>
<form action="$class->{'Cont'}->{'Url'}" method="post" name="nform">
<input type="hidden" name="edit_num" value="$id">
<input type="hidden" name="mode" value="quiz_edit_exec">
<table id="quiz_input">
<tr><td id="quiz_input_center" colspan="2">問題</td></tr>
<tr><td id="quiz_input_center_value" colspan="2">
<input type="text" name="quiz" size="50" value="$quiz">
</td></tr>
<td id="quiz_input_left">正解</td><td id="quiz_input_right">選択</td></tr>
<tr>
<td id="quiz_input_left_value">
<input type="radio" name="qcheck" value="1" $answer_1>
</td>
<td id="quiz_input_right_value">
<input type="text" name="quiz1" value="$quiz1" size="40">
</td></tr>
<tr>
<td id="quiz_input_left_value">
<input type="radio" name="qcheck" value="2" $answer_2>
</td>
<td id="quiz_input_right_value">
<input type="text" name="quiz2" value="$quiz2" size="40">
</td></tr>
<tr>
<td id="quiz_input_left_value">
<input type="radio" name="qcheck" value="3" $answer_3>
</td>
<td id="quiz_input_right_value">
<input type="text" name="quiz3" value="$quiz3" size="40">
</td></tr>
</table><br>
<input type="button" value=" 確認 " onclick="preview();">&nbsp;&nbsp;
<input type="button" value=" 修正 " onclick="edit_input_exec();">
</form><br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}



#クイズ修正・削除用リスト表示画面
sub quiz_edit
{
	my $class = shift;
	my $cgi = shift;
	my ($list,$max) = $class->{'Logic'}->quiz_data_read($cgi);
	if(!@$list)
	{
		&error($class,'まだ、クイズは登録されていません。');
	}
	#ページ送りのHTML作成
	my $page_html;
	my $page_max = $max / 10;
	if($page_max=~/\./)
	{
		$page_max = int($page_max);
		$page_max++;
	}
	my $cnt = 0;
	for(my $i=0;$i<$page_max;$i++)
	{
		$cnt++;
		my $link;
		if($i == $$cgi{'page'})
		{
			$link = qq|$cnt|;
		}else
		{
			$link = qq|<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit&page=$i">$cnt</a>|;
		}
		 $page_html .= qq|$link \||;
	}
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
管理画面
</div>
<br>
<div id="mente_menu">
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=mente_top">問題の登録</a>
</div>
<div id="mente_menu_in">
問題の修正・削除
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=rank_edit">ランキング管理</a>
</div>
</div>
<div style="clear:both;"></div><br>
<div id="page_list">$page_html</div>
<br>
<form action="$class->{'Cont'}->{'Url'}" method="POST" name="nform">
<input type="hidden" name="mode" value="quiz_delete_exec">
<input type="button" value="チェックしたクイズを削除" onclick="quiz_delete_exec();">
<br><br>
__END
	#ここでクイズ内容をリスト化する
	for(my $i=0;$i<@$list;$i++)
	{
		my $quiz = &tag_convert($$list[$i]{'quiz'});
		my $quiz1 = &tag_convert($$list[$i]{'quiz1'});
		my $quiz2 = &tag_convert($$list[$i]{'quiz2'});
		my $quiz3 = &tag_convert($$list[$i]{'quiz3'});
		$print .=<<"__END";
		<div id=loglist>
		<div id=logedit>
		&nbsp;
		<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit2&edit_num=$$list[$i]{'id'}">修正</a>
		&nbsp;
		<input type=checkbox name="delete_$$list[$i]{'id'}" value="on">
		</div>
		<div id=logtext>
		&nbsp;&nbsp;問題：$quiz
		<br>
		<li>$quiz1</li>
		<li>$quiz2</li>
		<li>$quiz3</li>
		</div>
		</div><br>
__END
	}
	$print .=<<"__END";
<br>
<input type="button" value="チェックしたクイズを削除" onclick="quiz_delete_exec();">
</form>
<div id="page_list">$page_html</div>
<br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}

#問題追加完了画面
sub input_finish
{
	my $class = shift;
	my $cgi = shift;
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
管理画面
</div>
<br>
<div id="mente_menu">
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=mente_top">問題の登録</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit">問題の修正・削除</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=rank_edit">ランキング管理</a>
</div>
</div>
<div style="clear:both;"></div><br><br>
問題追加が完了しました。
<br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}

#プレビュー画面
sub preview
{
	my $class = shift;
	my $cgi = shift;
	
	my $html;
	my $quiz = &tag_convert($$cgi{'quiz'});
	if($$cgi{'quiz1'} ne '')
	{
		my $ques = &tag_convert($$cgi{'quiz1'});
		$html .= <<"__END";
&nbsp;<input type="radio" name="ques">&nbsp;&nbsp;$ques<br>
__END
	}
	if($$cgi{'quiz2'} ne '')
	{
		my $ques = &tag_convert($$cgi{'quiz2'});
		$html .= <<"__END";
&nbsp;<input type="radio" name="ques">&nbsp;&nbsp;$ques<br>
__END
	}
	if($$cgi{'quiz3'} ne '')
	{
		my $ques = &tag_convert($$cgi{'quiz3'});
		$html .= <<"__END";
&nbsp;<input type="radio" name="ques">&nbsp;&nbsp;$ques<br>
__END
	}
	
	my $print = &head($class);
	$print .= <<"__END";
	<br>
	<div id=title>
	問題プレビュー
	</div><br><br>
	<div id=quizing>
	<br>
	&nbsp;&nbsp;問題：$quiz<br><br>
	$html
	<br>
	<center><input type="button" name="quiz_button" value="回答する"></center>
	<br>
	</div>
	<br><input type="button" value="この画面を閉じる" onclick="window.close();"><br><br>
	</div></body></html>
__END
	return($print);
}

#管理画面TOPページ
sub mente_top
{
	my $class = shift;
	my $cgi = shift;
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
管理画面
</div>
<br>
<div id="mente_menu">
<div id="mente_menu_in">
問題の登録
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=quiz_edit">問題の修正・削除</a>
</div>
<div id="mente_menu_in">
<a href="$class->{'Cont'}->{'Url'}?mode=rank_edit">ランキング管理</a>
</div>
</div>
<div style="clear:both;"></div><br><br>
<form action="$class->{'Cont'}->{'Url'}" method="post" name="nform">
<input type="hidden" name="mode" value="quiz_input_exec">
<table id="quiz_input">
<tr><td id="quiz_input_center" colspan="2">問題</td></tr>
<tr><td id="quiz_input_center_value" colspan="2">
<input type="text" name="quiz" size="50">
</td></tr>
<td id="quiz_input_left">正解</td><td id="quiz_input_right">選択</td></tr>
<tr>
<td id="quiz_input_left_value">
<input type="radio" name="qcheck" value="1" $answer_1>
</td>
<td id="quiz_input_right_value">
<input type="text" name="quiz1" size="40">
</td></tr>
<tr>
<td id="quiz_input_left_value">
<input type="radio" name="qcheck" value="2" $answer_2>
</td>
<td id="quiz_input_right_value">
<input type="text" name="quiz2" size="40">
</td></tr>
<tr>
<td id="quiz_input_left_value">
<input type="radio" name="qcheck" value="3" $answer_3>
</td>
<td id="quiz_input_right_value">
<input type="text" name="quiz3" size="40">
</td></tr>
</table><br>
<input type="button" value=" 確認 " onclick="preview();">&nbsp;&nbsp;
<input type="button" value=" 登録 " onclick="input_exec();">
</form><br><br>
[ <a href="$class->{'Cont'}->{'Url'}">Top</a> ]
<br><br>
__END
	$print .= &foot;
	return($print);
}

#管理ログイン画面
sub login_view
{
	my $class = shift;
	my $cgi = shift;
	my $print = &head($class);
	$print .=<<"__END";
<br>
<div id=title>
ログイン画面
</div>
<br>
<div id="pass_input">
<form action="$class->{'Cont'}->{'Url'}" method="POST">
<input type="hidden" name="mode" value="mente_top">
パスワード：<input type="password" name="InputPass" size="25">&nbsp;<input type="submit" value="ログイン">
</form>
</div>
<br><br>
__END
	$print .= &foot;
	return($print);
}

#クイズ開始認証
sub ques_start
{
	my $class = shift;
	my $cgi = shift;
	my $rid = $class->{'Logic'}->quiz_start_save();
	my $print = qq|content-type:text/html\n\n$rid|;
	return($print);
}

#クイズ問題リスト出力
sub ques_answer
{
	my $class = shift;
	my $cgi = shift;
	my ($status,$taken_time,$ok_ave);
	if($$cgi{'ques'} ne '')
	{
		#回答番号があれば答え合わせ
		
		($status,$taken_time,$ok_ave) = $class->{'Logic'}->quiz_answer_save($cgi);
		if($status != 1)
		{
			#エラー時は何も返さない
			return();
		}
	}
	my $list = $class->{'Logic'}->quiz_count_list_get($cgi);
	if($list eq '')
	{
		#エラー時は何も返さない
		return();
	}
	my $html;
	my $cnt = 0;
	my $ok_num = $$list{'answer'};
	if($$list{'quiz'} ne '')
	{
		my $quiz = &tag_convert($$list{'quiz'});
		$html .= <<"__END";
&nbsp;&nbsp;問題：$quiz<br><br>
__END
	}
	for(my $i=0;$i<3;$i++)
	{
		$cnt++;
		my $ques = &tag_convert($$list{"quiz$cnt"});
		if($ques eq '')
		{
			next;
		}
		$html .= <<"__END";
&nbsp;<input type="radio" name="ques" id="ques$cnt" value="$cnt">&nbsp;&nbsp;<b>$ques</b><br>
__END
	}
	my $print;
	
	if($html)
	{
		$print = <<"__END";
content-type:text/html\n\n
<br>
$html
<br>
<center><input type="button" name="quiz_button" value="回答する" onclick="quiz_exec();"></center>
<br>
__END
	}else
	{
		#かかった時間を分表示
		#分換算
		my $min = int($taken_time / 60);
		my $sec = int($taken_time % 60);
		$print = <<"__END";
content-type:text/html\n\n
<center>
<br>
問題に全て回答しました。<br>
成績は以下の通りです。<br>
<br>
<div style="text-align:left;margin:auto;width:200px;padding:5px;">
かかった時間: <b>$min分 $sec秒</b><br>
　　　　正答率: <b>$ok_ave\%</b>
</div><br>
ランキングに参加しますか？<br>
<br>
最後に一言(全角40文字以内)<br>
<textarea name="one_mes" id="one_mes"></textarea><br>
<input type="button" name="quiz_button" value="　はい　" onclick="rank_exec('$class->{'Cont'}->{'Url'}');">&nbsp;&nbsp;
<input type="button" name="quiz_button" value="いいえ" onclick="location.href = '$class->{'Cont'}->{'Url'}'">
</center>
<br>
__END
	}
	return $print;
}

#ランキング参加(ajax用)
sub rank_start
{
	my $class = shift;
	my $cgi = shift;
	my $ret = $class->{'Logic'}->rank_start($cgi);
	my $print;
	if($ret == 1)
	{
		$print =<<"__END";
content-type:text/html\n\nok
__END
		chomp($print);
	}
	return($print);
}

sub quiz_start
{
	my $class = shift;
	my $cgi = shift;
	my $name = $class->{'Logic'}->quiz_form_encode($$cgi{'name'});
	if(!$name)
	{
		&error($class,'お名前を入力してください。');
	}
	my $print = &head($class);
	$print =~s/<body>/<body onload="quiz_start();">/;
	$print .= <<"__END";
	<br>
	<div id=title>
	問題
	</div><br>
	<form action="$class->{'Cont'}->{'Url'}" method="POST" name="nform">
	<input type="hidden" name="mode" value="">
	<input type="hidden" name="name" value="$name">
	<input type="hidden" name="answer_count" value="0">
	<input type="hidden" name="rid" value="0">
	<div id=quizing>
	</div>
	</form>
__END
	$print .= &foot;
	return($print);
}

sub head
{
	my $class = shift;
	my $print =<<"__END";
content-type:text/html\n\n
<html>
<title>$class->{'Cont'}->{'Title'}</title>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="paragma" content="no-cache">
<link rel="stylesheet" href="$class->{'Cont'}->{'CssUrl'}" type="text/css" />
<script language="javascript" src="$class->{'Cont'}->{'PrototypeUrl'}">
</script>
<script language="javascript" src="$class->{'Cont'}->{'JsUrl'}">
</script>
</head>
<body>
<div id=all>
__END
	return $print;
}

sub foot
{
	my $class = shift;
	my $print = <<"__END";
<div id=foot>
<hr size=1>
<font size="2">
<a href="http://homepage1.nifty.com/kanayan/" target=_blank>&copy;Making CGI</a></font>
<br><br>
</div>
</div>
</body></html>
__END

	return $print;
}
#通常エラー
sub error
{
	my $class = shift;
	my $error = shift;
	my $print = &head($class);
	$print .= <<"__END";
<br><br>
<font color="#FF0000">
$error<br><br>
<script language=javascript>
<!--
	if(window.opener)
	{
		document.write('<input type="button" value="画面を閉じる" onclick="window.close()">');
	}else
	{
		document.write('<input type="button" value=" 戻る " onclick="history.back()">');
	}
//-->
</script>
</font>
<br><br>
__END
	$print .= &foot($class);
	print $print;
	exit;
}

#Ajax用エラー
sub ajax_error
{
	my $class = shift;
	$print =<<"__END";
content-type:text/html\n\nNG
__END
	chomp($print);
	return $print;
}

#view用encode
sub tag_convert
{
	my $class = shift if(ref($_[0])=~/^QuizLogic/);
	my $word = shift;
	$word =~s/</&lt;/g;
	$word =~s/>/&gt;/g;
	$word =~s/\"/&quot;/g;
	return($word);
}

#View用Encode 改行あり
sub tag_br_convert
{
	my $class = shift if(ref($_[0])=~/^QuizLogic/);
	my $word = shift;
	$word =~s/<br>/\tbr\t/g;
	$word =~s/</&lt;/g;
	$word =~s/>/&gt;/g;
	$word =~s/\"/&quot;/g;
	$word =~s/\tbr\t/<br>/g;
	return($word);
}
1;
