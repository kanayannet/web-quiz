function rank_delete_exec()
{
	if(confirm('このまま、削除しますが\nよろしいですか？'))
	{
		document.nform.mode.value = 'rank_delete_exec';
		document.nform.target = '';
		document.nform.submit();
	}
}


function quiz_delete_exec()
{
	if(confirm('このまま、削除しますが\nよろしいですか？'))
	{
		document.nform.mode.value = 'quiz_delete_exec';
		document.nform.target = '';
		document.nform.submit();
	}
}

function edit_input_exec()
{
	if(confirm('このまま、修正しますが\nよろしいですか？'))
	{
		document.nform.mode.value = 'quiz_edit_exec';
		document.nform.target = '';
		document.nform.submit();
	}
}

function input_exec()
{
	if(confirm('このまま、問題追加しますが\nよろしいですか？'))
	{
		document.nform.mode.value = 'input_exec';
		document.nform.target = '';
		document.nform.submit();
	}
}

function preview()
{
	window.open(document.nform.action,'quiz_preview','toolbar=no,location=no,status=no,scrollbars=yes,width=900,height=450');
	document.nform.mode.value = 'preview';
	document.nform.target = 'quiz_preview';
	document.nform.submit();
}

function quiz_start()
{
	var html;
	document.nform.answer_count.value = 0;
	new Ajax.Request(document.nform.action,{  method:'POST',
				asynchronous:false,
				parameters: {mode: 'ques_start'},
				onSuccess: function(transport)
				{
					html = transport.responseText;
				}

				});
	if(html == '0')
	{
		alert("クイズ認証が正常に行われませんでした。\n認証ファイルが壊れている可能性があります。");
		return;
	}
	document.nform.rid.value = html;
	html = "<b>Now Loading...</b>";
	new Ajax.Request(document.nform.action,{  method:'POST',
				asynchronous:true,
				parameters: {
						mode:'ques_ans',
						answer_count:document.nform.answer_count.value},
				onSuccess: function(transport)
				{
					if(transport.responseText == undefined)
					{
						alert("正常に処理が終了しませんでした\n\n恐れ入りますがTOPページから入りなおしてください。");
						return;
					}
					
					$("quizing").innerHTML = transport.responseText;
				}

				});
	
	document.nform.answer_count.value++;
	$("quizing").innerHTML = html;
}

function quiz_exec()
{
	var html;
	//NULLが来るかもしれないので。。それぞれ3回ループ
	// safari 対策↓
	var ques_value = null;
	for(var i=0;i<3;i=i+1)
	{
		if($('ques1'))
		{
			if($('ques1').checked)
			{
				ques_value = 1;
			}
		}
		if($('ques2'))
		{
			if($('ques2').checked)
			{
				ques_value = 2;
			}
		}
		if($('ques3'))
		{
			if($('ques3').checked)
			{
				ques_value = 3;
			}
		}
		if(ques_value > 0)
		{
			break;
		}
	}
	
	if(ques_value == undefined)
	{
		alert('問題を選択してください。');
		return;
	}
	html = "<b>Now Loading...</b>";
	new Ajax.Request(document.nform.action,{  method:'POST',
				asynchronous:true,
				parameters: {
						
						ques:ques_value,
						rid:document.nform.rid.value,
						mode: 'ques_ans',
						answer_count: document.nform.answer_count.value},
				onSuccess: function(transport)
				{
					if(transport.responseText == undefined)
					{
						alert("正常に処理が終了しませんでした\n\n恐れ入りますがTOPページから入りなおしてください。");
						return;
					}
					setTimeout(function(){
					$("quizing").innerHTML = transport.responseText;},300);
					
				}

				});
	
	document.nform.answer_count.value++;
	$("quizing").innerHTML = html;
}

function rank_exec(url)
{
	var html;
	if('あ'.length == 1)
	{
		//lengthマルチバイト対応
		if(document.nform.name.value.length > 10)
		{
			alert('お名前は10文字以内です。');
			return;
		}
		if($('one_mes').value.length > 40)
		{
			alert('「一言メッセージ」は40文字以内です。');
			return;
		}
	}else
	{
		//lengthマルチバイト非対応
		if(document.nform.name.value.length > 30)
		{
			alert('お名前は10文字以内です。');
			return;
		}
		if($('one_mes').value.length > 120)
		{
			alert('「一言メッセージ」は40文字以内です。');
			return;
		}
	}
	new Ajax.Request(document.nform.action,{  method:'POST',
				asynchronous:false,
				parameters: {
						rid:document.nform.rid.value,
						mode: 'rank_start',
						name:document.nform.name.value,
						one_mes:$('one_mes').value},
				onSuccess: function(transport)
				{
					html = transport.responseText;
				}

				});
	if(html != 'ok')
	{
		alert("正常に処理が終了しませんでした\n\n恐れ入りますがTOPページから入りなおしてください。");
		return;
	}
	location.href = url;
}