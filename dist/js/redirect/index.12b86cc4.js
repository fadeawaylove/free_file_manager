import{a as c}from"../vue-router/vue-router.e1418bca.js";import{u as n,c as p,o as u}from"../@vue/@vue.d04ec679.js";import"../@amap/@amap.58aba9ee.js";const _={name:"Redirect"},y=Object.assign(_,{setup(i){const{currentRoute:e,replace:r}=c(),{params:a,query:o}=n(e),{path:t}=a,s=Array.isArray(t)?t.join("/"):t;return r({path:"/"+s,query:o}),(m,f)=>(u(),p("div"))}});export{y as default};