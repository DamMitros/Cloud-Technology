const express=require('express');
const app=express();

app.get('/',(req,res)=>{
  const now=new Date();
  res.json({
    date: now.toLocaleDateString(),
    time: now.toLocaleTimeString()
  });
});

app.listen(8080,()=>{
  console.log('Server działa na http://localhost:8080');
});
