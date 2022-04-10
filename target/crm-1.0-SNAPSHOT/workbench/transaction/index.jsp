<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function(){

		pageList(1,5);

		$("#searchBtn").click(function (){
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-customerId").val($.trim($("#search-customerId").val()));
			$("#hidden-stage").val($.trim($("#search-stage").val()));
			$("#hidden-type").val($.trim($("#search-type").val()));
			$("#hidden-source").val($.trim($("#search-source").val()));
			$("#hidden-contactsId").val($.trim($("#search-contactsId").val()));

			pageList(1,5);
		})

		//	使用总复选框控制
		$("#checkbox").click(function (){
			$("input[name=checkboxItem]").prop("checked",this.checked);
		})

		//	使用其他控制总复选框
		$("#tranBody").on("click",$("input[name=checkboxItem]"),function (){
			$("#checkbox").prop("checked",$("input[name=checkboxItem]").length == $("input[name=checkboxItem]:checked").length);
		})

		//	为修改按钮绑定事件
		$("#editBtn").click(function (){

			var $checkItem = $("input[name=checkboxItem]:checked");
			if ($checkItem.length == 0){
				alert("亲亲，请选择要修改的交易！");
			}else if ($checkItem.length > 1){
				alert("亲亲，只能选择一条修改的交易！");
			}else {
				//	只选择了一条交易
				var id = $checkItem.val();
				window.location.href='workbench/transaction/edit.do?tranId='+ id;
			}
		})

		//	为删除按钮绑定事件
		$("#deleteBtn").click(function (){

			var $checkboxItems = $("input[name=checkboxItem]:checked");
			if ($checkboxItems.length == 0){
				alert("亲亲，请选择要删除的交易");
			}else {
				if (confirm("亲亲，确定要删除这些交易吗?")){

					var params = "";
					$.each($checkboxItems,function (i,checkboxItem){
						params += "id=" + $(checkboxItem).val();
						if (i < $checkboxItems.length -1 ){
							params += "&";
						}
					})
					$.ajax({

						url: "workbench/transaction/deleteTran.do",
						data: params,
						type: "post",
						success: function (data){
							if (data.success){
								pageList(1,$("#tranPageList").bs_pagination('getOption', 'rowsPerPage'));
							}else {
								alert(data.msg);
							}
						}
					})
				}
			}
		})
	});

	pageList = function (pageNo,pageSize){
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-customerId").val($.trim($("#hidden-customerId").val()));
		$("#search-stage").val($.trim($("#hidden-stage").val()));
		$("#search-type").val($.trim($("#hidden-type").val()));
		$("#search-source").val($.trim($("#hidden-source").val()));
		$("#search-contactsId").val($.trim($("#hidden-contactsId").val()));

		$.ajax({
			url: "workbench/transaction/pageList.do",
			data: {
				"owner": $("#search-owner").val(),
				"name": $("#search-name").val(),
				"customerId": $("#search-customerId").val(),
				"stage": $("#search-stage").val(),
				"type": $("#search-type").val(),
				"source": $("#search-source").val(),
				"contactsId": $("#search-contactsId").val(),

				"pageNo": pageNo,
				"pageSize": pageSize
			},
			type: "get",
			success: function (data){
				/*
					data
						{"total":xxx,"dataList":[{交易1},{2},{3}]}
				 */
				var html = "";
				$.each(data.dataList,function (index,Tran){
					html += "<tr class=\"active\">",
					html += "<td><input type=\"checkbox\" name='checkboxItem' value='"+ Tran.id +"'/></td>",
					html += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/transaction/detail.do?tranId="+ Tran.id +"';\">"+ Tran.name +"</a></td>",
					html += "<td>"+ Tran.customerId +"</td>",
					html += "<td>"+ Tran.stage +"</td>",
					html += "<td>"+ Tran.type +"</td>",
					html += "<td>"+ Tran.owner +"</td>",
					html += "<td>"+ Tran.source +"</td>",
					html += "<td>"+ Tran.contactsId +"</td>",
					html += "</tr>"
				})
				$("#tranBody").html(html);

				//	计算总页数
				var totalPages = data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//	数据处理完毕后，结合分页查询，对前端展现分页效果
				$("#tranPageList").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//	该回调函数是在 点击分页组件的时候触发的
					onChangePage : function(event, data){
						//	点击下一页的时候复选框清空
						$("#checkbox").prop("checked",false);

						pageList(data.currentPage , data.rowsPerPage);
					}
				});
			}
		})
	}
	
</script>
</head>
<body>
<input type="hidden" id="hidden-owner">
<input type="hidden" id="hidden-name">
<input type="hidden" id="hidden-customerId">
<input type="hidden" id="hidden-stage">
<input type="hidden" id="hidden-type">
<input type="hidden" id="hidden-source">
<input type="hidden" id="hidden-contactsId">

	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-customerId">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="search-stage">
					  	<option></option>
						  <c:forEach items="${stage}" var="stage">
							  <option value="${stage.value}">${stage.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="search-type">
					  	<option></option>
						  <c:forEach items="${transactionType}" var="transactionType">
							  <option value="${transactionType.value}">${transactionType.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${source}" var="source">
							  <option value="${source.value}">${source.text}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="search-contactsId">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='workbench/transaction/add.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn" ><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkbox"/></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="tranBody">
						<!--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/transaction/detail.jsp';">动力节点-交易01</a></td>
							<td>动力节点</td>
							<td>谈判/复审</td>
							<td>新业务</td>
							<td>zhangsan</td>
							<td>广告</td>
							<td>李四</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点-交易01</a></td>
                            <td>动力节点</td>
                            <td>谈判/复审</td>
                            <td>新业务</td>
                            <td>zhangsan</td>
                            <td>广告</td>
                            <td>李四</td>
                        </tr>-->
					</tbody>
				</table>
			</div>


			<div style="height: 50px; position: relative;top: 20px;">
				<div id="tranPageList">

				</div>
			</div>
			
		</div>
		
	</div>
</body>
</html>