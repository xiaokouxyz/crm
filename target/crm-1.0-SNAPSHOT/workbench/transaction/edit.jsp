<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
	Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");
	Set<String> set = pMap.keySet();
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
	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

	<script>
		$(function (){
			//	自动补全
			$("#edit-customerId").typeahead({
				source: function (query, process) {
					$.get(
							"workbench/transaction/getCustomerName.do",
							{ "name" : query },
							function (data) {
								//alert(data);
								process(data);
							},
							"json"
					);
				},
				delay: 500
			});

			//	时取器
			$(".time1").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			//	时取器
			$(".time2").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			var json = {

				<%
                    for (String key : set) {
                        String value = pMap.get(key);
                %>
				"<%=key%>" : <%=value%>,
				<%
                    }
                %>

			};

			//	取得选中的阶段
			var stage1 = $("#edit-stage").val();
			var possibility1 = json[stage1];
			$("#edit-possibility").val(possibility1);

			$("#edit-stage").change(function (){
				//	取得选中的阶段
				var stage1 = $("#edit-stage").val();
				var possibility1 = json[stage1];
				$("#edit-possibility").val(possibility1);
			})

			$("#boundActivityBtn").click(function (){
				$("#activityName").val("");
				$("#activitySearchBody").html("");
				$("input[name=activityRadio]").prop("checked",false);
			})

			$("#boundContactsBtn").click(function (){
				$("#contactsName").val("");
				$("#contactsSearchBody").html("");
				$("input[name=contactsRadio]").prop("checked",false);
			})

			//	为关联市场活动的模态窗口中的 搜索框 绑定事件，通过触发回车键，查询并展示所需市场活动列表
			$("#activityName").keydown(function (event){
				//	如果是回车键
				if (event.keyCode == 13){
					$.ajax({
						url: "workbench/transaction/getActivityListByNameAndNotByActivityId.do",
						data: {
							"activityName": $.trim($("#activityName").val()),
							"activityId": $("#activityId").val()
						},
						type: "get",
						success: function (data){
							/*
                                data
                                    [{活动1},{2},{3}]
                             */
							var html = "";
							$.each(data,function (index,activity){

								html += "<tr>";
								html += "<td><input type=\"radio\" name='activityRadio' onclick='boundActivity(\""+ activity.id +"\")'/></td>";
								html += "<td id='td"+ activity.id +"'>"+ activity.name +"</td>";
								html += "<td>"+ activity.startDate +"</td>";
								html += "<td>"+ activity.endDate +"</td>";
								html += "<td>"+ activity.owner +"</td>";
								html += "</tr>";
							})
							$("#activitySearchBody").html(html);
						}
					})
					//	展现完列表后，记得禁用模态窗口默认的回车行为
					return false;
				}
			})

			//	为关联联系人的模态窗口中的 搜索框 绑定事件，通过触发回车键，查询并展示所需联系人列表
			$("#contactsName").keydown(function (event){
				//	如果是回车键
				if (event.keyCode == 13){
					$.ajax({
						url: "workbench/contacts/getContactsListByNameAndNotByContactsId.do",
						data: {
							"contactsName": $.trim($("#contactsName").val()),
							"contactsId": $("#contactsId").val()
						},
						type: "get",
						success: function (data){
							/*
                                data
                                    [{1},{2},{3}]
                             */
							var html = "";
							$.each(data,function (index,contact){
								$("#contactsId").val(contact.id);
								html += "<tr>";
								html += "<td><input type=\"radio\" name=\"contactsRadio\" onclick='boundContacts(\""+ contact.id +"\")'/></td>";
								html += "<td id='td"+ contact.id +"'>"+ contact.fullname +"</td>";
								html += "<td>"+ contact.email +"</td>";
								html += "<td>"+ contact.mphone +"</td>";
								html += "</tr>";
							})
							$("#contactsSearchBody").html(html);
						}
					})
					//	展现完列表后，记得禁用模态窗口默认的回车行为
					return false;
				}
			})

			//	为保存按钮绑定事件，执行交易添加操作
			$("#updateTranBtn").click(function (){
				//发出传统请求，提交表单
				$("#tranForm").submit();
			})
		})

		function boundActivity(id){
			var name = $("#td"+id).text();
			$("#edit-activityId").val(name);
			$("#activityId").val(id);

			$("#findMarketActivity").modal("hide");
		}

		function boundContacts(id){
			var name = $("#td"+id).text();
			$("#edit-contactsId").val(name);
			$("#contactsId").val(id);

			$("#findContacts").modal("hide");
		}
	</script>

</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询" id="activityName">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable4" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询" id="contactsName">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="contactsSearchBody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>更新交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="updateTranBtn">更新</button>
			<button type="button" class="btn btn-default"  onclick="window.history.back();">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form action="workbench/transaction/updateTransaction.do" id="tranForm" method="post"  class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<input type="hidden" name="editBy" value="${user.name}">
		<input type="hidden" name="id" value="${tran.id}">
		<div class="form-group">
			<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-owner"  name="owner">
				  <option></option>
					<c:forEach items="${userList}" var="userList">
						<option value="${userList.id}" ${user.id eq userList.id ? "selected" : ""}>${userList.name}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-money" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-money" value="${tran.money}"  name="money">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-name" value="${tran.name}" name="name">
			</div>
			<label for="edit-expectedDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time1" id="edit-expectedDate" readonly placeholder="点击选择" value="${tran.expectedDate}" name="expectedDate">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-customerId" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-customerId" value="${tran.customerId}" name="customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="edit-stage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="edit-stage" selected="${tran.stage}" name="stage">
			  	<option></option>
				  <c:forEach items="${stage}" var="stage">
					  <option value="${stage.value}" ${tran.stage eq stage.value ? "selected" : ""}>${stage.text}</option>
				  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-type" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-type" selected="${tran.type}" name="type">
				  <option></option>
					<c:forEach items="${transactionType}" var="transactionType">
						<option value="${transactionType.value}" ${tran.type eq transactionType.value ? "selected" : ""}>${transactionType.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-possibility">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-source" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-source"  selected="${tran.source}" name="source">
				  <option></option>
					<c:forEach items="${source}" var="source">
						<option value="${source.value}" ${tran.source eq source.value ? "selected" : ""}>${source.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-activityId" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findMarketActivity" id="boundActivityBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-activityId" value="${tran.activityId}">
				<input type="hidden" name="activityId" id="activityId" value="${someIds.activityId}">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-contactsId" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findContacts" id="boundContactsBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-contactsId" value="${tran.contactsId}">
				<input type="hidden" name="contactsId" id="contactsId" value="${someIds.contactsId}">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-description" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-description" name="description" >${tran.description}</textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary" >${tran.contactSummary}</textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time2" id="create-nextContactTime" value="${tran.nextContactTime}" name="nextContactTime" readonly placeholder="点击选择">
			</div>
		</div>
		
	</form>
</body>
</html>