import{N as f,x as s,G as n,Q as h}from"./DapfKbp4.js";const q=f("despachador",()=>{const r=s([]),l=s([]),i=s([]),d=s(!1),c=s(null),v=n(()=>r.value.length),p=n(()=>l.value.length),_=n(()=>r.value.filter(o=>!i.value.includes(String(o.id))));return{vehiculosListos:r,vehiculosDespachados:l,despachados:i,loading:d,error:c,totalListosParaDespacho:v,totalDespachados:p,vehiculosPendienteDespacho:_,load:async()=>{d.value=!0,c.value=null;try{const{data:o,error:a}=await h.from("vehiculos").select(`
          id,
          bin,
          qr_codigo,
          color,
          estado,
          usuario_recibe_id,
          modelo_id,
          buque_id,
          modelos_vehiculo:modelo_id (
            id,
            marca,
            modelo,
            anio
          )
        `).eq("estado","listo_despacho").order("created_at",{ascending:!1});if(a){console.error("Error cargando vehículos para despacho:",a),c.value=`Error: ${a.message}`;return}if(!o){r.value=[];return}r.value=o.map(e=>({id:e.id,bin:e.bin||"",qr_codigo:e.qr_codigo,color:e.color,estado:e.estado,usuario_recibe_id:e.usuario_recibe_id,modelo_id:e.modelo_id,buque_id:e.buque_id,modelo:Array.isArray(e.modelos_vehiculo)?e.modelos_vehiculo[0]:e.modelos_vehiculo,cliente:e.cliente||null})),console.log(`Despachador: Cargados ${r.value.length} vehículos listos para despacho`)}catch(o){console.error("Error en load():",o),c.value="Error desconocido al cargar vehículos"}finally{d.value=!1}},despacharVehiculo:async(o,a)=>{try{const e=r.value.find(u=>u.id===o);if(!e)return{success:!1,error:"Vehículo no encontrado"};const{error:t}=await h.from("vehiculos").update({estado:"despachado"}).eq("id",o);return t?(console.error("Error actualizando vehículo:",t),{success:!1,error:`Error: ${t.message}`}):(i.value.push(String(o)),l.value.push(e),r.value=r.value.filter(u=>u.id!==o),{success:!0,despacho_id:String(o)})}catch(e){return console.error("Error en despacharVehiculo():",e),{success:!1,error:"Error desconocido"}}},getByBin:o=>r.value.find(a=>a.bin===o),getDetalles:o=>r.value.find(a=>a.id===o)}});export{q as u};
