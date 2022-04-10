<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function(){
		
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		//	时取器
		$(".time1").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-right"
		});
		$(".time2").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-right"
		});

		$("#create-customerName").typeahead({
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
		$("#edit-customerName").typeahead({
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

		$("#addBtn").click(function (){
			$.ajax({
				url: "workbench/contacts/getUserList.do",
				type: "get",
				dataType: "json",
				success: function (data){
					//	获取用户信息列表
					/*
						data
							[{用户1},{2},{3}]
					 */
					var html = "<option></option>";
					$.each(data,function (index,user){
						html += "<option value='"+ user.id +"'>"+ user.name +"</option>";
					})

					$("#create-owner").html(html);
					var id = "${user.id}";
					$("#create-owner").val(id);

					//	处理完下拉框之后，打开模态窗口
					$("#createContactsModal").modal("show");
				}
			})
		})

		//	为修改按钮绑定事件
		$("#editBtn").click(function (){

			//	获取打勾的复选框
			var $checkboxItems = $("input[name=checkboxItem]:checked");
			if ($checkboxItems.length == 0){
				alert("亲，请选择要修改的客户！");
			}else if ($checkboxItems.length >1){
				alert("亲，只能选择一个客户哦！");
			}else {

				//	只选择了一个活动
				var id = $checkboxItems.val();

				$.ajax({
					url: "workbench/contacts/getUserListAndContact.do",
					data:{
						"id": id
					},
					type: "get",
					dataType: "json",
					success: function (data){
						//	获取用户信息列表
						/*
                            data
                                {"userList":[{用户1},{用户2},{用户3}],"customer":{市场活动}}
                         */
						var html = "<option></option>";
						$.each(data.userList,function (index,user){
							html += "<option value='"+ user.id +"'>"+ user.name +"</option>";
						})
						$("#edit-owner").html(html);

						$("#edit-id").val(data.contact.id);
						$("#edit-owner").val(data.contact.owner);
						$("#edit-source").val(data.contact.source);
						$("#edit-customerName").val(data.contact.customerId);
						$("#edit-fullname").val(data.contact.fullname);
						$("#edit-appellation").val(data.contact.appellation);
						$("#edit-email").val(data.contact.email);
						$("#edit-mphone").val(data.contact.mphone);
						$("#edit-job").val(data.contact.job);
						$("#edit-birth").val(data.contact.birth);
						$("#edit-description").val(data.contact.description);
						$("#edit-contactSummary").val(data.contact.contactSummary);
						$("#edit-nextContactTime").val(data.contact.nextContactTime);
						$("#edit-address").val(data.contact.address);

						//	处理完下拉框之后，打开模态窗口
						$("#editContactsModal").modal("show");
					}
				})
			}
		})

		pageList(1,5);

		//	复选框
		$("#checkbox").click(function (){
			$("input[name=checkboxItem]").prop("checked",this.checked);
		})

		$("#contactsBody").on("click",$("input[name=checkboxItem]"),function (){
			$("#checkbox").prop("checked",$("input[name=checkboxItem]").length == $("input[name=checkboxItem]:checked").length);
		})

		//	为查询按钮绑定事件
		$("#searchBtn").click(function (){
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-fullname").val($.trim($("#search-fullname").val()));
			$("#hidden-customerId").val($.trim($("#search-customerId").val()));
			$("#hidden-source").val($.trim($("#search-source").val()));
			$("#hidden-birth").val($.trim($("#search-birth").val()));

			pageList(1,5);
		})

		//	为保存按钮绑定事件
		$("#saveBtn").click(function (){

			$.ajax({
				url: "workbench/contacts/saveContact.do",
				data: {
					"owner": $.trim($("#create-owner").val()),
					"source": $.trim($("#create-source").val()),
					"fullname": $.trim($("#create-fullname").val()),
					"appellation": $.trim($("#create-appellation").val()),
					"email": $.trim($("#create-email").val()),
					"mphone": $.trim($("#create-mphone").val()),
					"job": $.trim($("#create-job").val()),
					"birth": $.trim($("#create-birth").val()),
					"createBy": "${user.name}",
					"description": $.trim($("#create-description").val()),
					"contactSummary": $.trim($("#create-contactSummary").val()),
					"nextContactTime": $.trim($("#create-nextContactTime").val()),
					"address": $.trim($("#create-address").val()),

					"customerName": $.trim($("#create-customerName").val()),
				},
				type:"post",
				success: function (data){
					if (data.success){
						pageList(1,$("#ContactsPageList").bs_pagination('getOption', 'rowsPerPage'));
						$("#createContactsModal").modal("hide");
						$("#contactAddForm")[0].reset();
					}else {
						alert(data.msg);
					}
				}
			})
		})

		//	为更新按钮绑定事件
		$("#updateBtn").click(function (){

			$.ajax({

				url: "workbench/contacts/updateContact.do",
				data: {
					"id": $("#edit-id").val(),
					"owner": $.trim($("#edit-owner").val()),
					"source": $.trim($("#edit-source").val()),
					"fullname": $.trim($("#edit-fullname").val()),
					"appellation": $.trim($("#edit-appellation").val()),
					"email": $.trim($("#edit-email").val()),
					"mphone": $.trim($("#edit-mphone").val()),
					"job": $.trim($("#edit-job").val()),
					"birth": $.trim($("#edit-birth").val()),
					"editBy": "${user.name}",
					"description": $.trim($("#edit-description").val()),
					"contactSummary": $.trim($("#edit-contactSummary").val()),
					"nextContactTime": $.trim($("#edit-nextContactTime").val()),
					"address": $.trim($("#edit-address").val()),

					"customerName": $.trim($("#edit-customerName").val()),
				},
				type:"post",
				success: function (data){
					if (data.success){
						pageList(1,$("#ContactsPageList").bs_pagination('getOption', 'rowsPerPage'));
						$("#editContactsModal").modal("hide");
					}else {
						alert(data.msg);
					}
				}
			})
		})

		//	为删除按钮绑定事件
		$("#deleteBtn").click(function (){
			//	找到所有复选框打勾的jquery对象
			var $checkboxItems = $("input[name=checkboxItem]:checked");

			//	没选删除对象
			if ($checkboxItems.length == 0){
				alert("请选择你要删除的对象！");
			}else {
				//	肯定选了，1条或多条
				if (confirm("你确定要删除线索？")){
					var parameter = "";
					//	循环的每一部分就是单个复选框,dom对象
					$.each($checkboxItems,function (i,checkboxItem){
						parameter += "id=" + $(checkboxItem).val();
						if (i < $checkboxItems.length - 1){
							parameter += "&";
						}
					})

					$.ajax({
						url: "workbench/contacts/deleteContacts.do",
						data: parameter,
						type: "post",
						success: function (data){
							/*
								data
									["success":true/false,"msg":...]
							*/
							if (data.success){
								//	刷新列表
								pageList(1,$("#cluePageList").bs_pagination('getOption', 'rowsPerPage'));
							}else {
								//	失败弹窗
								alert(data.msg);
							}
						}
					})
				}
			}
		})


	});


	function pageList(pageNo,pageSize){
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-fullname").val($.trim($("#hidden-fullname").val()));
		$("#search-customerId").val($.trim($("#hidden-customerId").val()));
		$("#search-source").val($.trim($("#hidden-source").val()));
		$("#search-birth").val($.trim($("#hidden-birth").val()));

		$.ajax({

			url: "workbench/contacts/pageList.do",
			data: {
				"owner": $("#search-owner").val(),
				"fullname": $("#search-fullname").val(),
				"customerId": $("#search-customerId").val(),
				"source": $("#search-source").val(),
				"birth": $("#search-birth").val(),

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
				$.each(data.dataList,function (i,contact){
					html += "<tr class=\"active\">";
					html += "<td><input type=\"checkbox\" name='checkboxItem' value='"+ contact.id +"'/></td>";
					html += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/contacts/detail.do?id="+ contact.id +"';\">"+ contact.fullname +"</a></td>";
					html += "<td>"+ contact.customerId +"</td>";
					html += "<td>"+ contact.owner +"</td>";
					html += "<td>"+ contact.source +"</td>";
					html += "<td>"+ contact.birth +"</td>";
					html += "</tr>";
				})
				$("#contactsBody").html(html);

				//	计算总页数
				var totalPages = data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//	数据处理完毕后，结合分页查询，对前端展现分页效果
				$("#ContactsPageList").bs_pagination({
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
<input type="hidden" id="hidden-fullname">
<input type="hidden" id="hidden-customerId">
<input type="hidden" id="hidden-source">
<input type="hidden" id="hidden-birth">
	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="contactAddForm">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
								</select>
							</div>
							<label for="create-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
								  <option></option>
									<c:forEach items="${source}" var="source">
										<option value="${source.value}">${source.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
									<c:forEach items="${appellation}" var="appellation">
										<option value="${appellation.value}">${appellation.text}</option>
									</c:forEach>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time1" id="create-birth" readonly placeholder="点击选择">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time2" id="create-nextContactTime" readonly placeholder="点击选择">
								</div>
							</div>
						</div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">

								</select>
							</div>
							<label for="edit-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
								  <option></option>
									<c:forEach items="${source}" var="source">
										<option value="${source.value}">${source.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname">
							</div>
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <option></option>
									<c:forEach items="${appellation}" var="appellation">
										<option value="${appellation.value}">${appellation.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job">
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email">
							</div>
							<label for="edit-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time1" id="edit-birth" readonly placeholder="点击选择">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time2" id="edit-nextContactTime" readonly placeholder="点击选择">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>


	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>联系人列表</h3>
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
				      <div class="input-group-addon">姓名</div>
				      <input class="form-control" type="text" id="search-fullname">
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
				      <div class="input-group-addon">生日</div>
				      <input class="form-control time1" type="text" id="search-birth" readonly placeholder="点击选择">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 20px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkbox"/></td>
							<td>姓名</td>
							<td>客户名称</td>
							<td>所有者</td>
							<td>来源</td>
							<td>生日</td>
						</tr>
					</thead>
					<tbody id="contactsBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/contacts/detail.jsp';">李四</a></td>
							<td>动力节点</td>
							<td>zhangsan</td>
							<td>广告</td>
							<td>2000-10-10</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/contacts/detail.jsp';">李四</a></td>
                            <td>动力节点</td>
                            <td>zhangsan</td>
                            <td>广告</td>
                            <td>2000-10-10</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>


			<div style="height: 50px; position: relative;top: 10px;">
				<div id="ContactsPageList"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>