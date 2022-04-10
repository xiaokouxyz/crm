<%@ page import="com.kou.crm.settings.domain.DicValue" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
	//	准备字典类型为stage的字典值列表
	List<DicValue> dicValueList = (List<DicValue>) application.getAttribute("stage");

	//	准备阶段和可能性之间的对应关系
	Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");

	//	根据pMap准备pMap中的key集合
	Set<String> set = pMap.keySet();

	//	准备:前面正常阶段和后面丢失阶段的分界点下标
	Integer point = 0;
	for (int i = 0; i < dicValueList.size(); i++) {
		//	取得每一个字典值
		DicValue dicValue = dicValueList.get(i);

		//	从dicValue中取得value
		String stage = dicValue.getValue();
		//	根据stage取得possibility
		String possibility = pMap.get(stage);

		//	如果可能性为0，说明找到了前面正常阶段和后面丢失阶段的分界点
		if ("0".equals(possibility)){
			point = i;
			break;
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

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

		//	两个样式
		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})

		showCustomerRemarkList();

		//	保存备注按钮
		$("#saveBtn").click(function (){

			$.ajax({

				url: "workbench/customer/saveCustomerRemark.do",
				data: {
					"noteContent": $.trim($("#remark").val()),
					"createBy": "${user.name}",
					"editFlag": "0",
					"customerId": "${customer.id}"
				},
				type: "post",
				success: function (data){
					if (data.success){

						$("#remark").val("");
						showCustomerRemarkList();

					}else {
						alert(data.msg);
					}
				}
			})
		})

        //	为更新按钮绑定事件
        $("#updateRemarkBtn").click(function (){
            var id = $("#remarkId").val();

            $.ajax({
                url: "workbench/customer/updateRemark.do",
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
                            {"success":true/false,"msg":更新成功还是失败,"customerRemark":{备注}}
                            备注中包括：修改后的信息noteContent，修改时间editTime，修改人editBy
                     */
                    if (data.success){
                        //	修改备注成功
                        //	更新div中相应的信息，需要更新的内容有 noteContent、editTime、editBy
                        $("#h5"+ id).html(data.customerRemark.noteContent);
                        $("#small"+ id).html(data.customerRemark.editTime+" 由"+data.customerRemark.editBy);

                        //	更新之后，关闭模态窗口
                        $("#editRemarkModal").modal("hide");
                    }else {
                        //	修改备注失败
                        alert(data.msg);
                    }
                }
            })
        })

		showTranAndContactList();

		$("#addContactsBtn").click(function (){
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

		//	为保存按钮绑定事件
		$("#saveContactsBtn").click(function (){

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

						$("#createContactsModal").modal("hide");
						$("#contactAddForm")[0].reset();
					}else {
						alert(data.msg);
					}
				}
			})
		})
	});


	function showCustomerRemarkList(){

		$.ajax({
			url: "workbench/customer/showCustomerRemarkList.do",
			data: {
				"id": "${customer.id}"
			},
			type: "get",
			success: function (data){
				/*
					data
						[{备注1},{备注2},{3}..]
				 */
				var html = "";

				$.each(data,function (i,remark){

					html += "<div class=\"remarkDiv\" style=\"height: 60px;\">";
					html += "<img title=\"zhangsan\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
					html += "<div style=\"position: relative; top: -40px; left: 40px;\" >";
					html += "<h5 id='h5"+ remark.id +"'>"+ remark.noteContent +"</h5>";
					html += "<font color=\"gray\">公司</font> <font color=\"gray\">-</font> <b>-${customer.name}</b> <small style=\"color: gray;\" id=small"+ remark.id +"> "+ (remark.editFlag==0?remark.createTime:remark.editTime) +" 由"+ (remark.editFlag==0?remark.createBy:remark.editBy) +"</small>";
					html += "<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
					html += "<a class=\"myHref\" href=\"javascript:void(0);\" onclick='editRemark(\""+ remark.id +"\")'><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
					html += "&nbsp;&nbsp;&nbsp;&nbsp;";
					html += "<a class=\"myHref\" href=\"javascript:void(0);\" onclick='deleteRemark(\""+ remark.id +"\")'><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
					html += "</div>";
					html += "</div>";
					html += "</div>";
				})
				$("#customerRemarkDiv").html(html);
			}
		})
	}

	//  将备注信息铺到模态窗口上
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


	function deleteRemark(id){

		if (confirm("亲亲，你确定要删除这条备注吗？")){

			$.ajax({

				url: "workbench/customer/deleteRemark.do",
				data: {
					"id": id
				},
				type: "post",
				success: function (data){
					if (data.success){
						showCustomerRemarkList();
					}else {
						alert(data.msg);
					}
				}
			})
		}
	}

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

	//	展现交易信息
	function showTranAndContactList(){

		$.ajax({

			url: "workbench/customer/showTranAndContactList.do",
			data: {
				"id": "${customer.id}"
			},
			type: "get",
			success: function (data){
				/*
					data
						{
							"tranList":[{交易1},{2},{3}],
							"contactList":[{联系人1},{2},{3}]
						}
				 */
				var tranHtml = "";
				var conHtml = "";
				//	交易
				$.each(data.tranList,function (i,tran){
					//	取得选中的阶段
					var stage1 = tran.stage;
					var possibility1 = json[stage1];

					tranHtml += "<tr>";
					tranHtml += "<td><a href=\"workbench/transaction/detail.do?tranId="+ tran.id +"\" style=\"text-decoration: none;\">"+ tran.customerId +"-"+ tran.name +"</a></td>";
					tranHtml += "<td>"+ tran.money +"</td>";
					tranHtml += "<td>"+ tran.stage +"</td>";
					tranHtml += "<td>"+ possibility1 +"</td>";
					tranHtml += "<td>"+ tran.expectedDate +"</td>";
					tranHtml += "<td>"+ tran.type +"</td>";
					tranHtml += "<td><a class=\"myHref\" href=\"javascript:void(0);\" onclick='deleteTran(\""+ tran.id +"\")'><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #5bc0de;\"></span></a></td>";
					tranHtml += "</tr>";
				})
				$("#tranBody").html(tranHtml);

				//	联系人
				$.each(data.contactList,function (i,contact){

					conHtml += "<tr>";
					conHtml += "<td><a href=\"workbench/contacts/detail.do?id="+ contact.id +"\" style=\"text-decoration: none;\">"+ contact.fullname +"</a></td>";
					conHtml += "<td>"+ contact.email +"</td>";
					conHtml += "<td>"+ contact.mphone +"</td>";
					conHtml += "<td><a class=\"myHref\" href=\"javascript:void(0);\" onclick='deleteCon(\""+ contact.id +"\")'><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #5bc0de;\"></span></a></td>";
					conHtml += "</tr>";
				})
				$("#contactBody").html(conHtml);
			}
		})
	}

	//	为联系人删除按钮绑定事件
	function deleteCon(id){

		if (confirm("亲亲，确定要删除吗？")){
			$.ajax({

				url: "workbench/customer/deleteCon.do",
				data: {
					"id": id
				},
				type: "post",
				success: function (data){

					if (data.success){

						showTranAndContactList();
					}else {
						alert(data.msg);
					}
				}
			})

		}

	}

	//	为交易删除按钮绑定事件
	function deleteTran(id){

		if (confirm("亲亲，确定要删除吗？")){

			$.ajax({

				url: "workbench/customer/deleteTran.do",
				data: {
					"id": id
				},
				type: "post",
				success: function (data){

					if (data.success){

						showTranAndContactList();
					}else {
						alert(data.msg);
					}
				}
			})
		}

	}
</script>

</head>
<body>

    <!-- 修改客户备注的模态窗口 -->
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

	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
									<c:forEach items="${userList}" var="userList">
										<option value="${userList.id}" ${user.id eq userList.id ? "selected" : ""}>${userList.name}</option>
									</c:forEach>
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
								<input type="text" class="form-control time1" id="create-birth"  readonly placeholder="点击选择">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" value="${customer.name}" readonly>
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
					<button type="button" class="btn btn-primary" id="saveContactsBtn">保存</button>
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
			<h3>${customer.name} <small><a href="'+ ${customer.website} +'" target="_blank">${customer.website}</a></small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">

		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customer.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customer.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${customer.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${customer.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${customer.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${customer.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 40px;">
            <div style="width: 300px; color: gray;">联系纪要</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${customer.contactSummary}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
        <div style="position: relative; left: 40px; height: 30px; top: 50px;">
            <div style="width: 300px; color: gray;">下次联系时间</div>
            <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.nextContactTime}</b></div>
            <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
        </div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${customer.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 70px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${customer.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 10px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<div id="customerRemarkDiv"></div>
		<%--<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">联系人</font> <font color="gray">-</font> <b>李四先生-北京动力节点</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>

		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">联系人</font> <font color="gray">-</font> <b>李四先生-北京动力节点</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable2" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tranBody">
						<%--<tr>
							<td><a href="workbench/transaction/detail.jsp" style="text-decoration: none;">动力节点-交易01</a></td>
							<td>5,000</td>
							<td>谈判/复审</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>新业务</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeTransactionModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="workbench/transaction/add.do" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 联系人 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>联系人</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>邮箱</td>
							<td>手机</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="contactBody">
						<%--<tr>
							<td><a href="workbench/contacts/detail.jsp" style="text-decoration: none;">李四</a></td>
							<td>lisi@bjpowernode.com</td>
							<td>13543645364</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="addContactsBtn" data-toggle="modal" data-target="#createContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
			</div>
		</div>
	</div>
	
	<div style="height: 200px;"></div>
</body>
</html>