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
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function(){

		//	时取器
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-right"
		});

		//	为创建按钮绑定事件，打开添加操作的模态窗口
		$("#addBtn").click(function (){

			//	时取器
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			/*
			* 	操作模态窗口的方式:
				需要操作的模态窗口的jquery对象，调用modal方法，为该方法传递参数
					show:打开模态窗口
					hide:关闭模态窗口
			*/

			//	在模态窗口中，所有者需要从数据库中查询
			//	在打开模态窗口之前，拿到数据
			$.ajax({
				url : "workbench/activity/getUserList.do",
				type : "get",
				dataType : "json",
				success : function (data){
					//	拿到数据
					//	[{用户1},{用户2},{用户3}]
					var html = "<option>请选择</option>"
					$.each(data,function (index,json){
						//	这里循环的json就代表一个用户
						html += "<option value='" + json.id + "'>"+ json.name +"</option>"
					})
					$("#create-owner").html(html);

					//	取得当前用户的id
					//	在JS中使用EL表达式，EL表达式一定要套用在字符串中
					var userid = "${user.id}";
					$("#create-owner").val(userid);

					//	查询完数据之后再打开模态窗口
					$("#createActivityModal").modal("show");
				}
			})
		})

		//	为保存按钮绑定事件，执行添加操作
		$("#saveBtn").click(function (){
			$.ajax({
				url: "workbench/activity/saveActivity.do",
				data:{
					"owner": $.trim($("#create-owner").val()),
					"name": $.trim($("#create-name").val()),
					"startDate": $.trim($("#create-startDate").val()),
					"endDate": $.trim($("#create-endDate").val()),
					"cost": $.trim($("#create-cost").val()),
					"description": $.trim($("#create-description").val())
				},
				type: "post",
				dataType: "json",
				success:function(data){
					//	data       {"success":true/false}
					if (data.success){
						//	添加成功
						//	刷新市场活动信息列表（局部刷新）
						//pageList(1,2);
						/*
							$("#activityPage").bs_pagination('getOption', 'currentPage')
								操作停留在当前页

							$("#activityPage").bs_pagination('getOption', 'rowsPerPage')
								操作后维持已经设置好的每页展现的记录数

							这两个参数不需要我们进行任何的修改操作
							直接使用即可
						*/

						//做完添加操作后，应该回到第一页，维持每页展现的记录数
						pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));


						//	清空添加操作之后，模态窗口中的数据
						/*
							注意：
								我们拿到了form表单的jquery对象
								对于表单的jquery对象，提供了submit()方法用于提交form表单数据
								但是表单的jquery对象，没有为我们提供reset()方法让我们重置表单（坑！！！）

							虽然jquery对象没有为我们提供reset()方法，但是原生js为我们提供了reset方法
							所以我们要将jquery对象转换为原生dom对象

							jquery转dom：
								jquery对象[下标]

							dom转jquery：
								$(dom)
						 */
						$("#activityAddForm")[0].reset();

						//	关闭信息列表的模态窗口
						$("#createActivityModal").modal("hide");
					}else {
						alert(data.msg);
					}
				}
			})
		})

		//	页面加载完成后，触发一个方法
		pageList(1,5);

		//	为查询按钮绑定事件，触发pageList方法
		$("#searchBtn").click(function (){
			/*
			点击查询按钮时，将搜索框中的信息保存起来，保存到隐藏域中
			*/
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-startDate").val($.trim($("#search-startDate").val()));
			$("#hidden-endDate").val($.trim($("#search-endDate").val()));

			pageList(1,5);
		})

		//	为全选的复选框绑定事件，触发全选操作
		$("#checkbox").click(function (){
			$("input[name=xzCheckbox]").prop("checked",this.checked);
		})

		//以下这种做法是不行的
		/*	$( "input[name=xzCheckbox]").click(function () {
				alert(123);
			})
        */

		//因为动态生成的元素，是不能够以普通绑定事件的形式来进行操作的
		/*
        动态生成的元素，我们要以on方法的形式来触发事件

        语法:
        	$(需要绑定元素的有效的外层元素). on(绑定事件的方式，需要绑定的元素的jquery对象,回调函数)
		 */
		$("#activityBody").on("click",$("input[name=xzCheckbox]"),function (){
			$("#checkbox").prop("checked",$("input[name=xzCheckbox]").length == $("input[name=xzCheckbox]:checked").length);
		})

		//	为删除按钮绑定事件
		$("#deleteBtn").click(function (){
			//	找到复选框中所有打 √ 的jquery对象
			var $checkbox = $("input[name=xzCheckbox]:checked");

			if ($checkbox.length == 0){
				//	没有选择删除活动
				alert("请选择要删除的活动");
			}else {

				//	肯定选了，有可能是 1 条，也可能是多条
				if(confirm("确定删除所选中的记录吗？")){
					var parameter = "";
					$.each($checkbox,function (i,$oneCheckbox){
						parameter += "id=" + $($oneCheckbox).val();

						if (i < $checkbox.length - 1){
							parameter += "&";
						}
					})
					$.ajax({
						url: "workbench/activity/deleteActivity.do",
						data: parameter,
						type: "post",
						dataType: "json",
						success: function (data){
							/*
                                data
                                    {"success":true/false,"msg":失败信息}
                             */
							if (data.success){
								//	删除成功，局部刷新
								//pageList(1,2);
								//回到第一页，维持每页展现的记录数
								pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

							}else {
								alert(data.msg);
							}
						}
					})
				}

			}
		})


		//	为修改按钮绑定事件，打开修改操作的模态窗口
		$("#editBtn").click(function (){
			var $xzCheckbox = $("input[name=xzCheckbox]:checked");
			if ($xzCheckbox.length == 0){
				alert("请选择要修改的活动");
			}else if ($xzCheckbox.length > 1){
				alert("只能选择一个活动");
			}else {
				//	只选择了一个活动
				var id = $xzCheckbox.val();
				$.ajax({
					url: "workbench/activity/getUserListAndActivity.do",
					data:{
						"activityId": id
					},
					type: "get",
					dataType: "json",
					success: function (data){
						/*
							data
								{"userList":[{用户1},{用户2},{用户3}],"activity":{市场活动}}
						 */

						//	处理所有者下拉框
						var html = "<option></option>";
						$.each(data.userList,function (index,json){
							html += "<option value='"+ json.id +"'>"+ json.name +"</option>"
						})
						$("#edit-owner").html(html);

						//	处理单个活动
						$("#edit-id").val(data.activity.id);
						$("#edit-owner").val(data.activity.owner);
						$("#edit-name").val(data.activity.name);
						$("#edit-startDate").val(data.activity.startDate);
						$("#edit-endDate").val(data.activity.endDate);
						$("#edit-cost").val(data.activity.cost);
						$("#edit-description").val(data.activity.description);

						//	查询完数据之后再打开模态窗口
						$("#editActivityModal").modal("show");
					}

				})
			}
		})


		//	为更新按钮绑定事件，执行市场活动的修改操作
		/*
			在实际项目开发中，一定是按照先做添加，再做修改的这种顺序
			所以，为了节省开发时间，修改操作一般都是copy添加操作

		 */
		$("#updateBtn").click(function (){
			$.ajax({
				url: "workbench/activity/updateActivity.do",
				data:{
					"id": $.trim($("#edit-id").val()),
					"owner": $.trim($("#edit-owner").val()),
					"name": $.trim($("#edit-name").val()),
					"startDate": $.trim($("#edit-startDate").val()),
					"endDate": $.trim($("#edit-endDate").val()),
					"cost": $.trim($("#edit-cost").val()),
					"description": $.trim($("#edit-description").val())
				},
				type: "post",
				dataType: "json",
				success:function(data){
					//	data       {"success":true/false,"msg":修改成功还是失败}
					if (data.success){
						//	修改成功
						alert(data.msg)
						//	刷新市场活动信息列表（局部刷新）
						//pageList(1,2);
						pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));


						//	关闭信息列表的模态窗口
						$("#editActivityModal").modal("hide");
					}else {
						//	修改失败
						alert(data.msg);
					}
				}
			})
		})
	});

            /*
                对于所有的关系型数据库，做前端的分页相关的基础组件
                就是pageNo和pageSize
                pageNo：页码
                pageSize：每页展现的记录数

                pageList方法，就是发出Ajax请求到后台，从后台取得最新的市场活动信息列表
                            通过响应回来的数据，局部刷新市场活动列表

                我们都在哪些情况下，需要调用pageList方法（什么情况下需要刷新一下市场活动列表）
                （1）点击左侧菜单中的“市场活动”超链接，需要刷新市场活动列表，调用pageList方法
                （2）添加、修改、删除后，需要刷新市场活动信息列表，调用pageList方法
                （3）点击查询按钮的时候，需要刷新市场活动信息列表，调用pageList方法
                （4）点击分页组件的时候，需要刷新市场活动信息列表，调用pageList方法
                以上为pageList方法指定了六个入口，也就是说，在以上6个操作执行完毕后，我们需要调用pageList方法，
                刷新市场活动信息列表

             */
	pageList = function (pageNo , pageSize){
		$("#checkbox").prop("checked",false);


		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-startDate").val($.trim($("#hidden-startDate").val()));
		$("#search-endDate").val($.trim($("#hidden-endDate").val()));

		$.ajax({
			url: "workbench/activity/pageList.do",
			data: {
				"name": $.trim($("#search-name").val()),
				"owner": $.trim($("#search-owner").val()),
				"startDate": $.trim($("#search-startDate").val()),
				"endDate": $.trim($("#search-endDate").val()),

				"pageNo" : pageNo,
				"pageSize" : pageSize
			},
			type: "get",
			dataType: "json",
			success: function (data){
				/*
				data
					我们需要的
						[{市场活动1},{2},{3}]	List<Activity> listActivity
					一会分页插件需要的，查询的总记录数
						{"total":100}	int total

					{"total":100,"dataList":[{市场活动1},{2},{3}]}
				 */
				var html = "";
				//	每一个activity就是一个市场活动对象
				$.each(data.dataList,function (index,activity){
					html += "<tr class=\"active\">";
					html += "<td><input type=\"checkbox\" name='xzCheckbox' value='"+ activity.id +"'/></td>";
					html += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/detail.do?id="+ activity.id +"';\">"+ activity.name +"</a></td>";
					html += "<td>"+ activity.owner +"</td>";
					html += "<td>"+ activity.startDate +"</td>";
					html += "<td>"+ activity.endDate +"</td>";
					html += "</tr>";
				})
				$("#activityBody").html(html);

				//	计算总页数
				var totalPages = data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//	数据处理完毕后，结合分页查询，对前端展现分页效果
				$("#activityPage").bs_pagination({
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

						pageList(data.currentPage , data.rowsPerPage);
					}
				});
			}
		})
	}

</script>
</head>
<body>

	<!--隐藏域-->
	<input type="hidden" id="hidden-name">
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-startDate">
	<input type="hidden" id="hidden-endDate">


	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
									<!--这里通过Ajax填写-->
								</select>
							</div>
                            <label for="create-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-name">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startDate" readonly placeholder="点击选择">
							</div>
							<label for="create-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endDate" readonly placeholder="点击选择">
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
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
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
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
							<label for="edit-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startDate" readonly placeholder="点击选择">
							</div>
							<label for="edit-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endDate" readonly placeholder="点击选择">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<!--
									关于文本域textarea:
										(1) -定是要以标签对的形式来呈现,正常状态下标签对要紧紧的挨着
										(2) textarea虽然是以标签对的形式来呈现的，但是它也是属于表单元素范畴
										我们所有的对于textarea的取值和赋值操作，应该统一使用val()方法 (而不是htm()方法)
								-->
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
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
				<h3>市场活动列表</h3>
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
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control time" type="text" id="search-startDate"  readonly placeholder="点击选择"/>
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control time" type="text" id="search-endDate" readonly placeholder="点击选择">
				    </div>
				  </div>
				  
				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
					<!--
					点击创建按钮，观察两个属性和属性值
						data- toggle= "modal”:
						表示触发该按钮，将要打开一个模态窗口

						data- target= "#createActivityModal":
						表示要打开哪个模态窗口，通过#id的形式找到该窗口

						现在我们是以属性和属性值的方式写在了button元素中，用来打开模态窗口
						但是这样做是有问题的:
							问题在于没有办法对按钮的功能进行扩充

						所以未来的实际项目开发，对于触发模态窗口的操作，一定不要写死在元素当中，
						应该由我们自己写js代码来操作


					-->
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
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>