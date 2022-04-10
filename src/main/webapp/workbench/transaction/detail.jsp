<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.List" %>
<%@ page import="com.kou.crm.settings.domain.DicValue" %>
<%@ page import="com.kou.crm.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
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
		
		
		//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'bottom',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
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
		var stage1 = $("#stage").text();
		var possibility1 = json[stage1];
		$("#possibility").html(possibility1);

		showTranHistoryList();
	});
	
	function showTranHistoryList(){
		$.ajax({
			url: "workbench/transaction/getTranHistoryListByTranId.do",
			data: {
				"tranId": "${tran.id}"
			},
			type: "get",
			success: function (data){
				/*
					data
						[{交易历史1},{2},{3}]
				 */
				var html = "";
				$.each(data,function (index,tranHistory){
					html += "<tr>",
					html += "<td>"+ tranHistory.stage +"</td>",
					html += "<td>"+ tranHistory.money +"</td>",
					html += "<td></td>",
					html += "<td>"+ tranHistory.expectedDate +"</td>",
					html += "<td>"+ tranHistory.createTime +"</td>",
					html += "<td>"+ tranHistory.createBy +"</td>",
					html += "</tr>"
				});
				$("#tranHistoryBody").html(html);
			}
		})
	}

	/*
	方法:改变交易阶段
	参数:
		stage:需要改变的阶段
		i:需要改变的阶段对应的下标

	 */
	function changeStage(stage,i){
		if (confirm("亲亲，您确定要改变此阶段？")){
			$.ajax({
				url: "workbench/transaction/changeState.do",
				data: {
					"id": "${tran.id}",
					"stage": stage,
					"money": "${tran.money}",
					"expectedDate": "${tran.expectedDate}",
				},
				type: "post",
				success: function (data){
					/*
                        data
                            ["success":true/false,"msg":xxx,"tran":{交易1}]
                     */
					if (data.success){
						//	改变阶段成功后，需要在详细信息页上局部刷新 刷新阶段，可能性，修改人，修改时间
						$("#stage").html(data.tran.stage);

						$("#editBy").html(data.tran.editBy);
						$("#editTime").html(data.tran.editTime);

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

						var stage2 = $("#stage").html();
						var possibility2 = json[stage2];
						$("#possibility").html(possibility2);

						showTranHistoryList();

						//	改变阶段成功后
						//	(2)将所有的阶段图标重新判断，重新赋予样式及颜色
						changeIcon(stage,i);

					}else {
						alert(data.msg);
					}
				}
			})
		}
	}

	function changeIcon(stage,ind){
		//	当前阶段
		var currentStage = stage;
		//	当前阶段可能性
		var currentPossibility = $("#possibility").html();
		//	当前阶段的下标
		var index = ind;
		//	前面正常阶段和后面丢失阶段的分界点下标
		var point = "<%=point%>";
		//	如果当前页面的可能性为0，前7个一定是黑圈，后2个一个是黑叉，一个是红叉
		if (currentPossibility == "0"){

			//	遍历前7个
			for (var i = 0; i < point; i++) {
				//	黑圈---------------
				//	移除掉原有的样式
				$("#"+i).removeClass();
				//	添加新样式
				$("#"+i).addClass("glyphicon glyphicon-record mystage");
				//	为新样式赋予颜色
				$("#"+i).css("color","#000000");
			}
			//	遍历后两个
			for (var i = point; i < <%=dicValueList.size()%>; i++) {
				//	是否为当前阶段
				if (index == i){
					//	红叉---------------
					//	移除掉原有的样式
					$("#"+i).removeClass();
					//	添加新样式
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					//	为新样式赋予颜色
					$("#"+i).css("color","#FF0000");

				}else {
					//	黑叉---------------
					//	移除掉原有的样式
					$("#"+i).removeClass();
					//	添加新样式
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					//	为新样式赋予颜色
					$("#"+i).css("color","#000000");
				}
			}

		//	如果当前页面的可能性不为0，前7个绿圈、绿色标记、黑圈，后2个一定是黑叉
		}else {
			//	遍历前7个
			for (var i = 0; i < point; i++) {
				if (index == i){
					//	绿色标记--------------
					//	移除掉原有的样式
					$("#"+i).removeClass();
					//	添加新样式
					$("#"+i).addClass("glyphicon glyphicon-map-marker mystage");
					//	为新样式赋予颜色
					$("#"+i).css("color","#90F790");

				}else if (i < index){
					//	绿圈-----------------
					//	移除掉原有的样式
					$("#"+i).removeClass();
					//	添加新样式
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					//	为新样式赋予颜色
					$("#"+i).css("color","#90F790");

				}else {
					//	黑圈-----------------
					//	移除掉原有的样式
					$("#"+i).removeClass();
					//	添加新样式
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					//	为新样式赋予颜色
					$("#"+i).css("color","#000000");
				}
			}
			//	遍历后两个
			for (var i = point; i < <%=dicValueList.size()%>; i++) {
					//	黑叉---------------
					//	移除掉原有的样式
					$("#"+i).removeClass();
					//	添加新样式
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					//	为新样式赋予颜色
					$("#"+i).css("color","#000000");
			}

		}
	}
</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${tran.customerId}-${tran.name} <small>￥${tran.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">

		</div>
	</div>

	<!-- 阶段状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%
			//	准备当前阶段
			Tran tran = (Tran) request.getAttribute("tran");
			String currentStage = tran.getStage();
			//	准备当前阶段的可能性
			String currentPossibility = pMap.get(currentStage);

			//	判断当前阶段
			//	如果当前阶段的可能性为0，前7个一定是黑圈，后两个一个是红叉，，一个是黑叉
			if ("0".equals(currentPossibility)){
				for (int i = 0; i < dicValueList.size(); i++) {
					//	取得每一个遍历出来的阶段，根据每一个遍历出来的阶段取其可能性
					DicValue dicValue = dicValueList.get(i);
					String listStage = dicValue.getValue();
					String listPossibility = pMap.get(listStage);

					//	如果遍历出来的阶段可能性为0,说明是后两个，一个是红叉，，一个是黑叉
					if ("0".equals(listPossibility)){
						//	如果是当前阶段
						if (listStage.equals(currentStage)){
							//	红叉
		%>

			<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
				  class="glyphicon glyphicon-remove mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #FF0000;"></span>
			-----------

		<%

						//	如果不是当前阶段
						}else {
							//	黑叉
		%>

			<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
				  class="glyphicon glyphicon-remove mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
			-----------

		<%
						}
					}else {
						//	如果遍历出来的阶段可能性不为0，说明是前7个，一定是黑圈

						//	黑圈------------------------
		%>

			<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
				  class="glyphicon glyphicon-record mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
			-----------

		<%
					}
				}
			}else {
				//	如果当前阶段的可能性不为0,前7个有可能性是绿圈，绿色标记，黑圈，后两个一定是黑叉

				//	准备当前阶段的下标
				int index = 0;
				for (int i = 0; i < dicValueList.size(); i++) {
					DicValue dicValue = dicValueList.get(i);
					String stage = dicValue.getValue();
					//String possibility = pMap.get(stage);
					//	如果遍历出来的阶段是当前阶段
					if (stage.equals(currentStage)){
						index = i;
						break;
					}
				}

				for (int i = 0; i < dicValueList.size(); i++) {
					//	取得每一个遍历出来的阶段，根据每一个遍历出来的阶段取其可能性
					DicValue dicValue = dicValueList.get(i);
					String listStage = dicValue.getValue();
					String listPossibility = pMap.get(listStage);

					//	如果遍历出来的阶段的可能性为0，说明是后两个阶段
					if ("0".equals(listPossibility)){
						//	黑叉---------------
		%>

			<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
				  class="glyphicon glyphicon-remove mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
			-----------

		<%
					}else {
						//	如果遍历出来的阶段的可能性不为0，说明是前7个阶段绿圈，绿色标记，黑圈

						//	如果是当前阶段
						if (i == index){
							//	绿色标记--------------
		%>

			<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
				  class="glyphicon glyphicon-map-marker mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #90F790;"></span>
			-----------

		<%
						//	如果小于当前阶段
						}else if (i < index){
							//	绿圈---------------
		%>

			<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
				  class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #90F790;"></span>
			-----------

		<%
						//	如果大于当前阶段
						}else {
							//	黑圈----------------
		%>

			<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
				  class="glyphicon glyphicon-record mystage" data-toggle="popover"
				  data-placement="bottom" data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
			-----------

		<%
						}
					}
				}
			}


		%>
		<!--<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="资质审查" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="需求分析" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="价值建议" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="确定决策者" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="提案/报价" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="谈判/复审"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="成交"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="丢失的线索"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="因竞争丢失关闭"></span>
		------------->
		<span class="closingDate">${tran.expectedDate}</span>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${tran.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${tran.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${tran.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${tran.editBy}&nbsp;&nbsp;</b><small id="editTime" style="font-size: 10px; color: gray;">${tran.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${tran.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${tran.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.nextContactTime}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="tranHistoryBody">
						<!--<tr>
							<td>资质审查</td>
							<td>5,000</td>
							<td>10</td>
							<td>2017-02-07</td>
							<td>2016-10-10 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>需求分析</td>
							<td>5,000</td>
							<td>20</td>
							<td>2017-02-07</td>
							<td>2016-10-20 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>谈判/复审</td>
							<td>5,000</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>2017-02-09 10:10:10</td>
							<td>zhangsan</td>
						</tr>-->
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>