import{F as e}from"./FileSaver.min.7135435f.js";import{J as t}from"./index.890e76bb.js";import"./vendor.71a11aaa.js";import"./index.b3d949ba.js";import"./demo.14a768b4.js";import"./upload.e6c1def4.js";import"./file.56c9db88.js";import"./index.f3301aa0.js";function i(i,o,r,a){const n=new t,s=r||"file",p=a||"file";let m=`${i}\r\n`;o.forEach((e=>{let t="";t=e.toString(),m+=`${t}\r\n`})),n.file(`${s}.txt`,m),n.generateAsync({type:"blob"}).then((t=>{e.exports.saveAs(t,`${p}.zip`)}),(e=>{alert("导出失败")}))}export{i as export_txt_to_zip};