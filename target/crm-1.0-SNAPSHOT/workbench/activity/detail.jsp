<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
%><!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		showRemarkList();

		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})

		//	为保存按钮绑定事件，执行备注添加操作
		$("#saveRemarkBtn").click(function (){
			$.ajax({
				url: "workbench/activity/saveRemark.do",
				data: {
					"noteContent": $.trim($("#remark").val()),
					"activityId": "${activity.id}",
					"createBy": "${user.name}",
					"editFlag": "0"
				},
				type: "post",
				dataType: "json",
				success: function (data){
					/*
						data
							{"success":true/false,"activityRemark":{备注}}
					 */
					if (data.success){
						//	添加成功
						//	把textarea中的信息清空
						$("#remark").val("");

						//	在textarea文本域上方新增一个div
						var html = "";

						html += "<div id='"+ data.activityRemark.id +"' class=\"remarkDiv\" style=\"height: 60px;\">",
						html += "<img title=\"zhangsan\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">",
						html += "<div style=\"position: relative; top: -40px; left: 40px;\" >",
						html += "<h5>"+ data.activityRemark.noteContent +"</h5>",
						html += "<font color=\"gray\">市场活动</font> <font color=\"gray\">-</font> <b>${activity.name}</b> <small style=\"color: gray;\"> "+ (data.activityRemark.createTime) +" 由"+ (data.activityRemark.createBy) +"</small>",
						html += "<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">",
						html += "<a class=\"myHref\" href=\"javascript:void(0);\" onclick='editRemark(\""+ data.activityRemark.id +"\")'><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #FF0000;\"></span></a>",
						html += "&nbsp;&nbsp;&nbsp;&nbsp;",
						html += "<a class=\"myHref\" href=\"javascript:void(0);\" onclick='deleteRemark(\""+ data.activityRemark.id +"\")'><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #FF0000;\"></span></a>",
						html += "</div>",
						html += "</div>",
						html += "</div>",

						$("#remarkDiv").before(html);
					}else {
						//	添加备注失败
						alert(data.msg);
					}
				}
			})
		})

		//	为更新按钮绑定事件
		$("#updateRemarkBtn").click(function (){
			var id = $("#remarkId").val();

			$.ajax({
				url: "workbench/activity/updateRemark.do",
				data: {
					//	id,noteContent,editBy,editFlag
					"id": id,
					"noteContent": $.trim($("#noteContent").val()),
					"editBy": "${user.name}",
					"editFlag": "1"
				},
				type: "post",
				dataType: "json",
				success: function (data){
					/*
						data
							{"success":true/false,"msg":更新成功还是失败,"activityRemark":{备注}}
							备注中包括：修改后的信息noteContent，修改时间editTime，修改人editBy
					 */
					if (data.success){
						//	修改备注成功
						//	更新div中相应的信息，需要更新的内容有 noteContent、editTime、editBy
						$("#h5"+ id).html(data.activityRemark.noteContent);
						$("#small"+ id).html(data.activityRemark.editTime+" 由"+data.activityRemark.editBy);

						//	更新之后，关闭模态窗口
						$("#editRemarkModal").modal("hide");
					}else {
						//	修改备注失败
						alert(data.msg);
					}
				}
			})
		})
	});


	showRemarkList = function (){
		//	点击详情页、修改、删除、保存需要局部刷新
		$.ajax({
			url: "workbench/activity/getRemarkListByAid.do",
			data: {
				"activityId": "${activity.id}"
			},
			type: "get",
			dataType: "json",
			success: function (data){
				/**
				 * data
				 * 		[{备注1},{2},{3}]
				 */
				var html = "";
				$.each(data,function (index,json){

					html += "<div id='"+ json.id +"' class=\"remarkDiv\" style=\"height: 60px;\">",
					html += "<img title=\"zhangsan\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">",
					html += "<div style=\"position: relative; top: -40px; left: 40px;\" >",
					html += "<h5 id='h5"+ json.id +"'>"+ json.noteContent +"</h5>",
					html += "<font color=\"gray\">市场活动</font> <font color=\"gray\">-</font> <b>${activity.name}</b> <small style=\"color: gray;\" id='small"+ json.id +"'> "+ (json.editFlag==0?json.createTime:json.editTime) +" 由"+ (json.editFlag==0?json.createBy:json.editBy) +"</small>",
					html += "<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">",
					html += "<a class=\"myHref\" href=\"javascript:void(0);\" onclick='editRemark(\""+ json.id +"\")'><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #FF0000;\"></span></a>",
					html += "&nbsp;&nbsp;&nbsp;&nbsp;",
					html += "<a class=\"myHref\" href=\"javascript:void(0);\" onclick='deleteRemark(\""+ json.id +"\")'><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #FF0000;\"></span></a>",
					html += "</div>",
					html += "</div>",
					html += "</div>"
				})

				$("#remarkDiv").before(html);
			}
		})
	}

	function deleteRemark(id){
		if (confirm("亲亲，确定要删除吗？")){
			$.ajax({
				url: "workbench/activity/deleteRemark.do",
				data: {
					"id": id
				},
				type: "post",
				dataType: "json",
				success: function (data){
					/*
                        data
                            ["success":true/false,"msg":"成功还是失败"]
                     */
					if (data.success){
						//	刷新列表
						//这种做法不行，记录使用的是before方法，每一次删除之后，页面上都会保留原有的数据
						//showRemarkList();

						//找到需要删除记录的div，将div移 除掉
						$("#"+ id).remove();

					}else {
						alert(data.msg);
					}
				}
			})

		}
	}


	editRemark = function (id){
		//	将 id 保存在隐藏的文本域中
		$("#remarkId").val(id);

		//	拿到 h5 标签中的文本内容
		var $h5noteContent = $("#h5"+id).html();

		//	将 $h5noteContent 的文本内容添加到 修改备注模态窗口 中的文本域
		$("#noteContent").val($h5noteContent);

		//	将信息处理完之后，打开 修改备注的模态窗口
		$("#editRemarkModal").modal("show");
	}
</script>

</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改备注</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
                        <div class="form-group">
                            <label for="noteContent" class="col-sm-2 control-label">内容</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${activity.name} <small>${activity.startDate} ~ ${activity.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">

		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${activity.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 30px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<!--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>-->
		
		<!-- 备注2 -->
		<!--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>-->
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>