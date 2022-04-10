<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
		
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		pageList(1,5);

		//	根据条件模糊查询
		$("#searchBtn").click(function (){
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-phone").val($.trim($("#search-phone").val()));
			$("#hidden-website").val($.trim($("#search-website").val()));

			pageList(1,5);
		})

		//	点击总复选框操作其余复选框
		$("#checkbox").click(function (){
			$("input[name=checkboxItem]").prop("checked",this.checked);
		})

		//	点击其余复选框操作总复选框
		$("#customerBody").on("click",$("input[name=checkboxItem]"),function (){
			$("#checkbox").prop("checked",$("input[name=checkboxItem]:checked").length == $("input[name=checkboxItem]").length);
		})

		//	为创建按钮绑定事件，打开添加操作的模态窗口
		$("#addBtn").click(function (){

			//	时取器
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			$.ajax({

				url: "workbench/customer/getUserList.do",
				type: "get",
				success: function (data){

					var html = "";
					$.each(data,function (i,user){

						html += "<option value='" + user.id + "'>" + user.name + "</option>"
					})
					$("#create-owner").html(html);

					var userId = "${user.id}";
					$("#create-owner").val(userId);

					//	查询完数据之后再打开模态窗口
					$("#createCustomerModal").modal("show");
				}
			})
		})

		//	为保存按钮绑定事件
		$("#saveBtn").click(function (){

			$.ajax({

				url: "workbench/customer/saveCustomer.do",
				data: {
					"owner": $.trim($("#create-owner").val()),
					"name": $.trim($("#create-name").val()),
					"website": $.trim($("#create-website").val()),
					"phone": $.trim($("#create-phone").val()),
					"createBy": "${user.name}",
					"contactSummary": $.trim($("#create-contactSummary").val()),
					"nextContactTime": $.trim($("#create-nextContactTime").val()),
					"description": $.trim($("#create-description").val()),
					"address": $.trim($("#create-address").val())
				},
				type: "post",
				success: function (data){
					if (data.success){
						pageList(1,$("#customerPageList").bs_pagination('getOption', 'rowsPerPage'));
						$("#customerAddForm")[0].reset();

						//	关闭信息列表的模态窗口
						$("#createCustomerModal").modal("hide");
					}else {
						alert(data.msg);
					}
				}
			})
		})

		//	为修改按钮绑定事件
		$("#editBtn").click(function (){

			//	获取打勾的复选框
			var $checkboxItem = $("input[name=checkboxItem]:checked");
			if ($checkboxItem.length == 0){
				alert("亲，请选择要修改的客户！");
			}else if ($checkboxItem.length >1){
				alert("亲，只能选择一个客户哦！");
			}else {

				//	只选择了一个活动
				var id = $checkboxItem.val();

				$.ajax({

					url: "workbench/customer/getCustomer.do",
					data: {
						"id": id
					},
					type: "get",
					success: function (data){
						/*
							data
								{"userList":[{用户1},{用户2},{用户3}],"customer":{市场活动}}
						*/
						var html = "<option></option>";
						$.each(data.userList,function (i,user){

							html += "<option value='"+ user.id +"'>"+ user.name +"</option>"
						})
						$("#edit-owner").html(html);

						$("#edit-owner").val(data.customer.owner);
						$("#edit-id").val(data.customer.id);
						$("#edit-name").val(data.customer.name);
						$("#edit-website").val(data.customer.website);
						$("#edit-phone").val(data.customer.phone);
						$("#edit-contactSummary").val(data.customer.contactSummary);
						$("#edit-nextContactTime").val(data.customer.nextContactTime);
						$("#edit-description").val(data.customer.description);
						$("#edit-address").val(data.customer.address);

						$("#editCustomerModal").modal("show");
					}
				})
			}
		})

		//	为更新按钮绑定事件
		$("#updateBtn").click(function (){

			$.ajax({
				url: "workbench/customer/updateCustomer.do",
				data: {
					"id": $.trim($("#edit-id").val()),
					"owner": $.trim($("#edit-owner").val()),
					"name": $.trim($("#edit-name").val()),
					"website": $.trim($("#edit-website").val()),
					"phone": $.trim($("#edit-phone").val()),
					"editBy": "${user.name}",
					"contactSummary": $.trim($("#edit-contactSummary").val()),
					"nextContactTime": $.trim($("#edit-nextContactTime").val()),
					"description": $.trim($("#edit-description").val()),
					"address": $.trim($("#edit-address").val()),
				},
				type: "post",
				success: function (data){

					if (data.success){
						pageList($("#customerPageList").bs_pagination('getOption', 'currentPage')
								,$("#customerPageList").bs_pagination('getOption', 'rowsPerPage'));

						$("#editCustomerModal").modal("hide");
					}else {
						alert(data.msg);
					}
				}
			})
		})

		//	为删除按钮绑定事件
		$("#deleteBtn").click(function (){
			//	找到复选框中所有打 √ 的jquery对象
			var $checkbox = $("input[name=checkboxItem]:checked");

			if ($checkbox.length == 0){
				alert("亲亲，请选择要删除的客户哦！");
			}else {
				if (confirm("亲亲，确定要删除这些客户吗?")){

					var params = "";
					$.each($checkbox, function (i,checkboxItem){
						params += "id=" + $(checkboxItem).val();

						if (i < $checkbox.length - 1){
							params += "&";
						}
					})
					$.ajax({

						url: "workbench/customer/deleteCustomer.do",
						data: params,
						type: "post",
						success: function (data){
							if (data.success){
								pageList(1,$("#customerPageList").bs_pagination('getOption', 'rowsPerPage'));
							}else {
								alert(data.msg);
							}
						}
					})
				}
			}
		})
	});

	pageList = function (pageNo, pageSize){
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-phone").val($.trim($("#hidden-phone").val()));
		$("#search-website").val($.trim($("#hidden-website").val()));

		$.ajax({
			url: "workbench/customer/pageList.do",
			data: {
				"name": $("#search-name").val(),
				"owner": $("#search-owner").val(),
				"phone": $("#search-phone").val(),
				"website": $("#search-website").val(),

				"pageNo": pageNo,
				"pageSize": pageSize
			},
			type: "get",
			success: function (data){
				/*
					data
						{"total":xxx,"dataList":[{客户1},{2},{3}...]}
				 */
				var html = "";
				$.each(data.dataList,function (index,customer){
					html += "<tr class=\"active\">",
					html += "<td><input type=\"checkbox\" name='checkboxItem' value='"+ customer.id +"'/></td>",
					html += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/customer/detail.do?id="+ customer.id +"';\">"+ customer.name +"</a></td>",
					html += "<td>"+ customer.owner +"</td>",
					html += "<td>"+ customer.phone +"</td>",
					html += "<td>"+ customer.website +"</td>",
					html += "</tr>"
				})
				$("#customerBody").html(html);

				//	计算总页数
				var totalPages = data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//	数据处理完毕后，结合分页查询，对前端展现分页效果
				$("#customerPageList").bs_pagination({
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

	<input type="hidden" id="hidden-name">
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-phone">
	<input type="hidden" id="hidden-website">

	<!-- 创建客户的模态窗口 -->
	<div class="modal fade" id="createCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建客户</h4>
				</div>
				<div class="modal-body">
					<form id="customerAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
							<label for="create-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-name">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-website">
                            </div>
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
						</div>
						<div class="form-group">
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
                                    <input type="text" class="form-control time" id="create-nextContactTime" readonly placeholder="点击选择">
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
	
	<!-- 修改客户的模态窗口 -->
	<div class="modal fade" id="editCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改客户</h4>
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
							<label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-name">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website">
                            </div>
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone">
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
                                <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control" id="edit-nextContactTime" readonly placeholder="点击选择">
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
				<h3>客户列表</h3>
			</div>
		</div>
	</div>

	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="search-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司网站</div>
				      <input class="form-control" type="text" id="search-website">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkbox"/></td>
							<td>名称</td>
							<td>所有者</td>
							<td>公司座机</td>
							<td>公司网站</td>
						</tr>
					</thead>
					<tbody id="customerBody">
						<!--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/customer/detail.jsp';">动力节点</a></td>
							<td>zhangsan</td>
							<td>010-84846003</td>
							<td>http://www.bjpowernode.com</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/customer/detail.jsp';">动力节点</a></td>
                            <td>zhangsan</td>
                            <td>010-84846003</td>
                            <td>http://www.bjpowernode.com</td>
                        </tr>-->
					</tbody>
				</table>
			</div>

			<div id="customerPageList">

			</div>
			<!--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>-->
			
		</div>
		
	</div>
</body>
</html>