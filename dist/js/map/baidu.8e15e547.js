import{b as m}from"../index/index.5a342370.js";import{L as n}from"../index/index.9c51f221.js";import{_ as s}from"../../assets/index.e216368e.js";import{e as c,i as _,n as d,a7 as l,V as u,W as o,u as h,o as f,a1 as v,a as e,$ as i}from"../@vue/@vue.5f79e602.js";import"../element-plus/element-plus.50e7beae.js";import"../lodash-es/lodash-es.dd34ae20.js";import"../@vueuse/@vueuse.f476c204.js";import"../@amap/@amap.58aba9ee.js";import"../@popperjs/@popperjs.290efabf.js";import"../@ctrl/@ctrl.d23ee9f9.js";import"../dayjs/dayjs.136f6762.js";import"../async-validator/async-validator.fe815769.js";import"../memoize-one/memoize-one.26bd7615.js";import"../escape-html/escape-html.d572c0fd.js";import"../normalize-wheel-es/normalize-wheel-es.b3942336.js";import"../@floating-ui/@floating-ui.cc16a47b.js";import"../vue/vue.597d869f.js";import"../lodash-unified/lodash-unified.ab3d03cd.js";import"../pinia/pinia.f2a4981c.js";import"../vue-demi/vue-demi.4f3c4c97.js";import"../js-cookie/js-cookie.431252a9.js";import"../axios/axios.21f17a99.js";import"../geotiff/geotiff.09715990.js";import"../vue-router/vue-router.7ed29036.js";import"../path-to-regexp/path-to-regexp.ecb763cd.js";import"../fuse.js/fuse.js.8cd4e865.js";import"../path-browserify/path-browserify.3d3258d8.js";import"../screenfull/screenfull.468e47d2.js";import"../vue-i18n/vue-i18n.f84ab2b1.js";import"../@intlify/@intlify.848de760.js";import"../mitt/mitt.fcf4f812.js";import"../qs/qs.71f2d2b1.js";import"../side-channel/side-channel.147ab9b8.js";import"../get-intrinsic/get-intrinsic.c9f38a1e.js";import"../has-symbols/has-symbols.37c383d9.js";import"../function-bind/function-bind.20151ab8.js";import"../has/has.21528ef4.js";import"../call-bind/call-bind.45258027.js";import"../object-inspect/object-inspect.ddd6d7bd.js";import"../nprogress/nprogress.558663b1.js";/* empty css                                 *//* empty css                                 */import"../clipboard/clipboard.a3dfcb76.js";import"../@element-plus/@element-plus.d835247c.js";import"../xe-utils/xe-utils.d9e2cfb8.js";import"../vxe-table/vxe-table.9806638a.js";import"../vite-plugin-mock/vite-plugin-mock.65169573.js";import"../mockjs/mockjs.57e773d8.js";const M=i(" \u767E\u5EA6\u5730\u56FE\u7684\u7B80\u5355\u4F7F\u7528\uFF0C\u6700\u65B0\u7248GL\u5730\u56FE\u547D\u540D\u7A7A\u95F4\u4E3ABMapGL, \u53EF\u6309\u4F4F\u9F20\u6807\u53F3\u952E\u63A7\u5236\u5730\u56FE\u65CB\u8F6C\u3001\u4FEE\u6539\u503E\u659C\u89D2\u5EA6\u3002 "),y=i("\u70B9\u6211\u67E5\u770B\u66F4\u591A"),x={class:"section-container"},b={__name:"baidu",setup(B){const r=c(),p="ov7zC5g8Ac0ScLPp1zG8TZDuiGfty9Hh";return _(()=>{d(()=>{m(p).then(()=>{const t=new BMap.Map(r.value);t.centerAndZoom(new BMap.Point(116.404,39.915),11),t.addControl(new BMap.MapTypeControl({mapTypes:[BMAP_NORMAL_MAP,BMAP_HYBRID_MAP]})),t.setCurrentCity("\u5317\u4EAC"),t.enableScrollWheelZoom(!0)}).catch(t=>{console.log("err",t)})})}),(t,k)=>{const a=l("el-link");return f(),u(h(n),{title:"\u767E\u5EA6\u5730\u56FE"},{head:o(()=>[M,v(a,{type:"primary",href:"https://lbsyun.baidu.com/index.php?title=jspopularGL",target:"_blank",underline:!1},{default:o(()=>[y]),_:1})]),body:o(()=>[e("div",x,[e("div",{id:"container",ref_key:"container",ref:r},null,512)])]),_:1})}}};var Mt=s(b,[["__scopeId","data-v-dce391d2"]]);export{Mt as default};