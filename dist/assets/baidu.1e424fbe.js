import{b as e}from"./index.343f64e8.js";import{_ as a}from"./index.f0259f49.js";import{d as o,h as t,x as n,J as s,p as r,f as c,r as i,o as p,c as d,a as l,w as u}from"./vendor.b1565cd9.js";const m=o({name:"Baidu",components:{PageLayout:a},setup(){const a=t();return n((()=>{s((()=>{e("ov7zC5g8Ac0ScLPp1zG8TZDuiGfty9Hh").then((()=>{let e=new BMap.Map(a.value);e.centerAndZoom(new BMap.Point(116.404,39.915),11),e.addControl(new BMap.MapTypeControl({mapTypes:[BMAP_NORMAL_MAP,BMAP_HYBRID_MAP]})),e.setCurrentCity("北京"),e.enableScrollWheelZoom(!0)})).catch((e=>{console.log("err",e)}))}))})),{container:a}}}),M=u();r("data-v-eb1020ec");const f={class:"section-container "},B={id:"container",ref:"container"};c();const _=M(((e,a,o,t,n,s)=>{const r=i("page-layout");return p(),d(r,{title:"百度地图",subtitle:"百度地图的简单使用，最新版GL地图命名空间为BMapGL, 可按住鼠标右键控制地图旋转、修改倾斜角度。"},{body:M((()=>[l("div",f,[l("div",B,null,512)])])),_:1})}));m.render=_,m.__scopeId="data-v-eb1020ec";export default m;