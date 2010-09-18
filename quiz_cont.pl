package QuizCont;

#***************************
#	quiz 用コントローラー
#***************************


sub new
{
	my $class = shift;
	my %ret = @_;
	return bless{%ret},$class;
}

sub OutPut
{
	my $class = shift;
	my $cgi = &GetFormDecode;
	my $logic = QuizLogic->new($class);
	my $view = QuizView->new($class,$logic);
	my $print;
	if($$cgi{'mode'} eq '')
	{
		#初期画面表示
		$print = $view->TopPage;
	}elsif($$cgi{'mode'} eq 'quiz_start')
	{
		if(length($$cgi{'name'}) > 30)
		{
			$print = $view->ajax_error;
		}
		$print = $view->quiz_start($cgi);
	}elsif($$cgi{'mode'} eq 'ques_ans')
	{
		#クイズ問題回答  問題リスト出力
		$print = $view->ques_answer($cgi);
	}elsif($$cgi{'mode'} eq 'ques_start')
	{
		#クイズ問題開始認証
		$print = $view->ques_start($cgi);
		
	}elsif($$cgi{'mode'} eq 'rank_start')
	{
		#ランキング参加
		if(length($$cgi{'name'}) > 30)
		{
			$print = $view->ajax_error;
		}
		if(length($$cgi{'one_mes'}) > 120)
		{
			$print = $view->ajax_error;
		}
		if(!$print)
		{
			$print = $view->rank_start($cgi);
		}
	}elsif($$cgi{'mode'} eq 'mente_top')
	{
		#ログイン画面 および 新規登録画面
		my $login;
		if($$cgi{'InputPass'} ne '')
		{
			$login = $logic->login_set($cgi);
		}else
		{
			$login = $logic->login_chk($cgi);
		}
		if($login == 1)
		{
			$print = $view->mente_top($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'preview')
	{
		#preview画面
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			#引数チェック
			my $ret = $logic->quiz_input_chk($cgi);
			if($ret eq '1')
			{
			}else
			{
				$view->error($ret);
			}
			#表示
			$print = $view->preview($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'input_exec')
	{
		#クイズ追加処理
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			#引数チェック
			my $ret = $logic->quiz_input_chk($cgi);
			if($ret eq '1')
			{
			}else
			{
				$view->error($ret);
			}
			#保存処理実行
			my $save = $logic->quiz_input_save($cgi);
			if($save == 1)
			{
			}else
			{
				$view->error('ログファイルが壊れているか、保存できませんでした。');
			}
			print "location: $class->{'Url'}?mode=input_finish\n\n";
			exit;
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'input_finish')
	{
		#問題追加完了画面
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			$print = $view->input_finish($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'quiz_edit')
	{
		#修正削除のためのリスト画面
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			$print = $view->quiz_edit($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'quiz_edit2')
	{
		#修正画面
		
		my $login = $logic->login_chk($cgi);
		
		if($login == 1)
		{
			$print = $view->quiz_edit_view($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'quiz_edit_exec')
	{
		#修正完了処理
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			#引数チェック
			my $ret = $logic->quiz_input_chk($cgi);
			if($ret eq '1')
			{
			}else
			{
				$view->error($ret);
			}
			#保存処理実行
			my $save = $logic->quiz_input_save($cgi);
			if($save == 1)
			{
			}else
			{
				$view->error('ログファイルが壊れているか、保存できませんでした。');
			}
			print "location: $class->{'Url'}?mode=edit_finish\n\n";
			exit;
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'edit_finish')
	{
		#修正完了画面
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			$print = $view->edit_finish($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
		
	}elsif($$cgi{'mode'} eq 'quiz_delete_exec')
	{
		#クイズ削除処理
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
		}else
		{
			$print = $view->login_view($cgi);
		}
		#保存処理実行
		my $save = $logic->quiz_input_save($cgi);
		if($save == 1)
		{
		}else
		{
			$view->error('ログファイルが壊れているか、保存できませんでした。');
		}
		print "location: $class->{'Url'}?mode=delete_finish\n\n";
		exit;
	}elsif($$cgi{'mode'} eq 'delete_finish')
	{
		#削除完了画面
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			$print = $view->delete_finish($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'rank_edit')
	{
		#Ranking修正用一覧画面
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			$print = $view->rank_edit($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
		
	}elsif($$cgi{'mode'} eq 'rank_delete_exec')
	{
		#Ranking削除
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			my $ret = $logic->rank_delete_exec($cgi);
			if($ret == 0)
			{
				$view->error('ランキングデータが正しく削除できませんでした。');
			}
		}else
		{
			$print = $view->login_view($cgi);
		}
		print "location: $class->{'Url'}?mode=rank_delete_finish\n\n";
		exit;
	}elsif($$cgi{'mode'} eq 'rank_delete_finish')
	{
		#Ranking削除完了画面
		my $login = $logic->login_chk($cgi);
		if($login == 1)
		{
			$print = $view->rank_delete_finish($cgi);
		}else
		{
			$print = $view->login_view($cgi);
		}
	}elsif($$cgi{'mode'} eq 'rank_list')
	{
		$print = $view->rank_list($cgi);
	}
	return $print;
}

sub GetFormDecode
{
	my $query;
	# 環境変数取得
	if ($ENV{'REQUEST_METHOD'} eq "POST"){
		read(STDIN, $query, $ENV{'CONTENT_LENGTH'});
	} else {
		$query = $ENV{'QUERY_STRING'};
	}
	my %cgi;
	# デコード
	my @args = split(/&/, $query);
	foreach my $i (@args) {
		my ($name, $val) = split(/=/, $i);
		$val =~ tr/+/ /;
		$val =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack('C', hex($1))/eg;
		$cgi{$name} = $val;
	}
	return (\%cgi);
}

1;
