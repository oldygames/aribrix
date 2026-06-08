pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--███a█r█i█b█r█i█x███
--░░░multiply,match,feed░░░

local wo={{},{},{}}

function wo.updi(a)
	for i=1,#a do
		local l=a[i]
		for j=1,#l do
			local v=l[j]
			if v[19] then
				v[5],v[19]=v[19] end
			if v[20] then
				v[6],v[20]=v[20] end
			if v[21] then
				v[7],v[21]=v[21] end
			if v[22] then
				v[8],v[22]=v[22] end
		end
	end
end

function wo.ins(d,e,x)
	local a=wo[d]
	local l,r=1,#a
	local c1,c2,i1,t1,t2=
		     d,d+2,d+4,d+18,d+20
	while l<=r do
		local i=(l+r)\2
		local v=a[i]
		local vx=i==v[i1] and v[c1]
		                   or v[c2]
		if x<vx then r=i-1
		        else l=i+1	end
	end
	for i=l,#a do
		local v=a[i]
		if i==v[i1] then v[t1]=i+1
		            else v[t2]=i+1
		end
	end
	add(a,e,l)
	return l
end

function wo.add(e)
	local a=wo[3]
	e[5]=wo.ins(1,e,e[1])
	e[6]=wo.ins(2,e,e[2])
	wo.updi(a)
	e[7]=wo.ins(1,e,e[3])
	e[8]=wo.ins(2,e,e[4])
	wo.updi(a)
	if not e[9] then
		e[9],e[11],e[13],e[15],e[17]
		           =0,1,0,1,false end
	if not e[10] then
		e[10],e[12],e[14],e[16],e[18]
		           =0,1,0,1,false end
	local l=e.wl or 2
	for i=1,l do
		if not a[i] then a[i]={} end
	end
	local al=a[l]
	al[#al+1],e.wl=e,l
	return e
end

function wo.map(tx,ty,sx,sy,
                tw,th,f,l)
	tx,ty,sx,sy,tw,th,l=
	   tx or 0,ty or 0,sx or 0,
	   sy or 0,tw or 128,th or 64,
	   l or 1
	for i=ty,ty+th-1 do
		for j=tx,tx+tw-1 do
			local n=mget(j,i)
			if n~=0 and
			     (not f or fget(n)&f~=0)
			then
				local x,y=sx+(j-tx)*8,
				          sy+(i-ty)*8
				wo.add{x,y,x+7,y+7;
				       wl=l,ws=n}
			end
		end
	end
end

function wo.all(f,l)
	l=l or 0xfffe
	local a=wo[3]
	for i=1,#a do
		if l&2^(i-1)~=0 then
			local l=a[i]
			for j=1,#l do
				local v=l[j]
				local m=v[f]
				if not v.dead and m then
					m(v) end
			end
		end
	end
end

function wo.prg(l)
	l=l or 0xfffe
	for d=1,2 do
		local a,j=wo[d],1
		local z,i1,t1,t2=
		      #a,d+4,d+18,d+20
		for i=1,z do
			local v=a[i]
			if not v.dead then
				if i~=j then
					if i==v[i1] then v[t1]=j
					            else v[t2]=j
					end
					a[j]=v
				end
				j+=1
			end
		end
		for i=j,z do a[i]=nil end
	end
	local a=wo[3]
	wo.updi(a)
	for i=1,#a do
		if l&2^(i-1)~=0 then
			local l=a[i]
			local z,j=#l,1
			for k=1,z do
				local v=l[k]
				if not v.dead then
					if k~=j then l[j]=v end
					j+=1
				end
			end
			for i=j,z do l[i]=nil end
		end
	end
end

function wo.v(d,e,p,n)
	p,n=p or 0,n or 1
	local d8,d10,d16=d+8,d+10,d+16
	if e[d8]~=p or e[d10]~=n then
		e[d8],e[d10],e[d+12],e[d+14]
		                    =p,n,p,n
		if p~=0 or e[d16]==nil then
			e[d16]=p>0 end
	end
	return wo
end

function wo.adv(a,d,s,e,r)
	local u=s<0 and -1 or 1
	local p1,p2,c1,c2,i1,i2=3-d,5-d
	if not r and u<0 or r and u>0
	then c1,c2,i1,i2=d,d+2,d+4,d+6
	else c1,c2,i1,i2=d+2,d,d+6,d+4
	end
	local z,i,x0,wf,w,sf=
	      #a,e[i1]+u,e[c1],e.wf
	local px,pi,p=x0
	while 1<=i and i<=z do
		local n=a[i]
		local nx=n[i1]==i and n[c1]
		                   or n[c2]
		if p and nx~=px then
			local j,k=e[i1],i-u
			if p[i1]==k then p[i1]=j
			            else p[i2]=j
			end
			e[i1],a[j],a[k]=k,p,e
			e[c1],sf=px,false
		end
		local dx=nx-px
		p,pi,px=n,i,nx
		local l,m=s<0 and -s or s,
		          dx<0 and -dx or dx
		if l<m then break end
		if r or n.dead or
			  nx==x0 or n[i1]==i or
			  n[p2]<e[p1] or e[p2]<n[p1]
			  or wf and wf(e,n,d,u) then
			s-=dx
			sf=true
		else
			e[c1],w,s,sf=nx-u,n,0,false
			break
		end
		i+=u
	end
	if sf then
		local j,k=e[i1],pi
		if p[i1]==k then p[i1]=j
		            else p[i2]=j
		end
		e[c1],e[i1],a[j],a[k]=px,k,p,e
	end
	e[c1]+=s
	return w,e[c1]-x0
end

function wo.mv(e)
	local sx,sy=
	      (e[13]/e[15]+0.5)\1,
	      (e[14]/e[16]+0.5)\1
	local lx,ly,l1,w1,w2,r1,r2,
	      a1,a2,d1,d2,s1,s2=
	      sx<0 and -sx or sx,
	      sy<0 and -sy or sy
	if ly<lx then
		l1,a1,a2,d1,d2,s1,s2=
		ly,wo[2],wo[1],2,1,sy,sx
	else
		l1,a1,a2,d1,d2,s1,s2=
		lx,wo[1],wo[2],1,2,sx,sy
	end
	local u1,u2=s1<0 and -1 or 1,
	            s2<0 and -1 or 1
	if l1==0 then
		if s2~=0 then
			w2,r2=wo.adv(a2,d2,s2,e)
			wo.adv(a2,d2,r2,e,true)
		end
	else
		for l=l1,1,-1 do
			local s=(s2/l+0.5)\1
			w2,r2=wo.adv(a2,d2,s,e)
			wo.adv(a2,d2,r2,e,true)
			w1,r1=wo.adv(a1,d1,u1,e)
			wo.adv(a1,d1,r1,e,true)
			if w1 or w2 then break end
			s2-=s
		end
	end
	if e[15]==1
	then e[13],e[15]=e[9],e[11]
	else	e[13]-=sx e[15]-=1 end
	if e[16]==1
	then e[14],e[16]=e[10],e[12]
	else	e[14]-=sy e[16]-=1 end
	if w1 and w2 then
		return w1,d1,u1,w2,d2,u2
	elseif w1 then return w1,d1,u1
	elseif w2 then return w2,d2,u2
	end
end

function wo.rs(d,e,u,s)
	local l,r=e[d]-e[d+2],
	  u>0 and s<0 or u<0 and s>0
	if u>0 and s<l then s=l end
	if u<0 and s>-l then s=-l end
	return (wo.adv(wo[d],d,s,e,r))
end

function wo.sk(d,i,u)
	local a=wo[d]
	local z,v,c,k=#a,a[i],d+2,d+4
	local x=v[k]==i and v[d]
	                 or v[c]
	while 1<=i and i<=z do
		v=a[i]
		local vx=v[k]==i and v[d]
		                  or v[c]
		if vx~=x then break end
		i+=u
	end
	return i-u
end

function wo.nx(d,i,u,x1,x2,f,l)
	local a=wo[d]
	local z,k,p1,p2=#a,d+4,3-d,5-d
	i+=u
	while 1<=i and i<=z do
		local v=a[i]
		local b=v[k]==i
		local ex=u>0 and b or
		         u<0 and not b
		if not v.dead
		   and (f&1~=0 and b or
		        f&2~=0 and not b or
		        f&4~=0 and ex or
		        f&8~=0 and not ex)
		   and v[p2]>=x1 and v[p1]<=x2
		   and (not l
		      or l&2^(v.wl-1)~=0) then
			return i end
		i+=u
	end
end
-->8
local function mdr(m)
	local a=m.a
	spr(a[m.i],m[1],m[2],
	    a.x/8,a.y/8,m[17])
end

local function ewf()
	return true
end

function wo.swa(m,a)
	local p=m.a
	if p then
		if p.ex then p.ex(m) end
		local dx,wf=a.x-p.x
		wf,m.wf=m.wf,ewf
		if dx~=0 then
			local d1=dx\2
			local d2=dx%2==0 and d1
			                  or d1+1
			wo.rs(1,m,-1,-d1)
			wo.rs(1,m,1,d2)
		end
		local dy=a.y-p.y
		if dy~=0 then
			wo.rs(2,m,-1,-dy) end
		m.wf=wf
	elseif not m[3] then
		m[3],m[4]=m[1]+a.x-1,
		          m[2]+a.y-1
	end
	m.c,m.i,m.a,m.mv=0,1,a,a.mv
	if a.en then a.en(m) end
end

function wo.swb(m,b,...)
	local en,ex=b.en,m.b and m.b.ex
	if ex then ex(m) end
	m.wf,m.b=ewf,b
	if en then en(m,...) end
end

function wo.mob(b,l,x,y,...)
	local m={x,y;wl=l,dr=mdr}
	wo.swb(m,b,...)
	return wo.add(m)
end
-->8
local flt,gld,hvr,lkr,wlk,pck,
      sit,stn,swp,trc,dnc=
{64,70,67,70;x=20,y=16},
{77;x=18,y=9},
{73,75;x=16,y=15},
{38,32;x=16,y=13},
{34,36,34,38;x=16,y=13},
{40,42;x=16,y=10},
{104,106,108;x=9,y=13},
{104;x=9,y=13},
{96,98,100,102,100,98;x=11,y=15},
{128,135;x=50,y=32},
{206,110,238,110;x=16,y=16}

local lv,ba,bc,bp,bs,
   ml,mc,md,mp,ms,tm,wn,gx,gy,
   p,p1,p2,p3,ov,stp,mbs,mlv

function flt.mv(m)
	wo.mv(m)
	local i=m.c/4%4+1
	if i==2 then sfx(12) end
	m.i=i\1
	m.c+=1
	m.b.mv(m)
end

function gld.mv(m)
	wo.mv(m)
	m.c+=1
	m.b.mv(m)
end

function hvr.mv(m)
	local w1,d1,u,w2,d2=wo.mv(m)
	local i=m.c/3%2+1
	if i==2 then sfx(12) end
	m.i=i\1
	m.c+=1
	if d1==2 then w1,w2=w2,w1 end
	m.b.mv(m,w1,w2)
end

function lkr.mv(m)
	m.i=m.c\15%2+1
	m.c+=1
	m.b.mv(m)
end

function wlk.mv(m)
	local w=wo.mv(m)
	local i=m.c/4%4+1
	if i==2 or i==4 then
		sfx(13) end
	m.i=i\1
	m.c+=1
	m.b.mv(m,w)
end

function pck.en(m) m.p=0 end
function pck.ex(m) m.p=nil end

function pck.mv(m)
	if m.i==2 then
		if m.p>1 then m.i,m.p=1,0
		         else sfx(14) end
	else
		m.i=m.p>3 and rnd()<0.3 and 2
		                         or 1
		if m.i==2 then m.p=0 end
	end
	m.c+=1 m.p+=1
	m.b.mv(m,nil,m.i==2 and m.p==1)
end

function sit.en(m) m.s=0 end
function sit.ex(m) m.s=nil end

function sit.mv(m)
	if m.c==15 then m.i=2 end
	if m.i==2 and rnd()<0.005 then
		m.i=3 m.s=3 end
	if m.i==3 and m.s<0 then
		m.i=2 end
	m.c+=1 m.s-=1
	m.b.mv(m)
end

function stn.mv(m) m.b.mv(m) end

function swp.mv(m)
	wo.mv(m)
	local i=m.c/4%6+1
	if i==2 and lv then sfx(15) end
	m.i=i\1
	m.c+=1
	m.b.mv(m,i==3)
end

function trc.mv(m)
	local w=wo.mv(m)
	m.i=m.c\8%2+1
	m.c+=1
	m.b.mv(m,w)
end
-->8
local flin,flaw,flgd,flrf,flsk,
      wlgd,wlrf,swpb,trcb=
   {},{},{},{},{},{},{},{c=0},{}

local function lnp(m,x1,x2,l)
	local a,i=wo[2],wo.sk(2,m[8],1)
	i=wo.nx(2,i,1,x1,x2,1,l)
	if not i then return end
	local j,v=i,a[i]
	local y,b1,b2=v[2],v[1],v[3]
	if y<16 then return end
	while i do
		v=a[i]
		if v[2]~=y then break end
		local vx1,vx2=v[1],v[3]
		if vx1<b1 then b1=vx1 end
		if vx2>b2 then b2=vx2 end
		i=wo.nx(2,i,1,x1,x2,1,l)
	end
	i=wo.nx(2,j,-1,x1,x2,2,5)
	while i do
		v=a[i]
		if v.wl==3 and y-v[4]<=32 or
		   y-v[4]<=16 then return end
		i=wo.nx(2,i,-1,x1,x2,2,5)
	end
	return b1,b2,y-1
end

local function ctg(m)
	if m[4]~=119 then return end
	local u,px,d1,d2,s1,s2
	if m[17] then u,px=-1,m[3]-2
	         else u,px=1,m[1]+2 end
	local a,pi=wo[3][2],px\8
	local i=pi+u
	while 1<=i and i<=14 do
		local d=a[i]
		if d.g>0 then d1=d break end
		i+=u
	end
	i=pi
	while 1<=i and i<=14 do
		local d=a[i]
		if d.g>0 then d2=d break end
		i-=u
	end
	if d1 then
		s1=u<0 and px-d1[3]
		        or d1[1]-px end
	if d2 then
		s2=u<0 and d2[1]-px
		        or px-d2[3] end
	return s1,s2
end

local function ctr(m,w)
	m.rc,m.rn=m.rc or 0,m.rn or 0
	local v=m[9]
	if w or (v<0 and m[1]<1 or
	         v>0 and m[3]>126) then
		wo.v(1,m,-v,m[11])
		m.rc+=1
		if m.pc then m.pc=60 end
		if m.rf then
			local x,y=m[1],m[2]
			if m.rx==x and m.ry==y
			then m.rn+=1
			else m.rx,m.ry,m.rn=x,y,0 end
		end
		m.rf=not m.rf
	end
end

local function nt(d,e,u)
	local p1,p2,g,k=3-d,5-d,d+2,
	            u<0 and d+4 or d+6
	local i=wo.sk(d,e[k],u)
	i=wo.nx(d,i,u,e[p1],e[p2],4,4)
	local n=wo[d][i]
	if n and not n.tm and not n.mv
	     and (u<0 and n[g]==e[d]-1
	       or u>0 and n[d]==e[g]+1)
	then return n end
end

local function svh(m,h)
	local y=m[4]
	if y<h then
		wo.swa(m,gld) wo.v(2,m,1)
	elseif y>h then
		wo.swa(m,hvr) wo.v(2,m,-1)
	else
		wo.swa(m,flt) wo.v(2,m)
	end
end

local function tof(m,df)
	if m.g==0 then
		wo.swb(m,flaw)
	else wo.swb(m,flsk,df) end
end

local function brk(m,gd)
	m.rn=0
	if rnd()<0.4 or gd then
		wo.swb(m,flgd,70)
	else tof(m,20) end
end

local function wwf(m,w)
	if w.wl==6 then m.sw=true end
	return w.wl~=1 and w.wl~=3
end

local function fwf(m,w,d,u)
	if w.wl==6 then m.sw=true end
	return w.mv or d==1 or u==-1 or
	       w.wl~=2 and w.wl~=3
end

local function trs(t)
	wo.v(1,t,-1,3).v(2,t)
	function t.mv(t)
		local w,n=wo.mv(t),nt(2,t,-1)
		while n do
			wo.v(1,n,t[1]-n[1])
			  .v(2,n).mv(n)
			if n[3]<0 then
				n.dead=true end
			n.wf,n=ewf,nt(2,n,-1)
		end
		if t[3]<0 then t.dead=true end
		if w then trs(w) end
	end
	function t.wf(m,w)
		return w.wl~=3
	end
end

local function gov()
	?"\^wgame",15,1,8
	?"\^wover",83,1,8
end

local function glv()
	local l=dget(0)
	?"you did great there!",25,51,9
	?"keep going!",44,70,14
	?"       press ⬆️\nfor the next level:\fc"..l.."X"..l,22,89,6
	spr(4,59,30,2,2)
end

local gc,gp,gs=
      0,0,{57,104;a=dnc}

local function gbt()
	local t=stat(54)
	if t~=gp then
		gc,gp=gc\20*20+20,t end
	if #wn==0 or gc%20==0 then
		for i=1,10 do
			wn[i]=rnd()<0.5 and 6 or 7
		end
		gs.i=gc\20%4+1
	end
	gc+=1
	local x,y=0,24
	for i=1,10 do
		spr(wn[i],x,y,1,2)
		y+=16
		if y==104 then x,y=120,24 end
	end
	?"you beat the hardest level!\n that was a big challenge!",11,51,14
	?"    the pigeons\nare thankful to you!",26,69,9
	?"press ⬆️",49,87,6
	?"to play \fc9X9\f6 again.",30,93,6
	spr(241,14,72) spr(241,108,72)
	spr(142,56,29,2,2)
	spr(174,41,29,2,2)
	spr(174,71,29,2,2,true)
	mdr(gs)
end

function flin.en(m)
	wo.swa(m,flt)
	wo.v(1,m,m[1]<0 and 1 or -1)
	  .v(2,m)
end

function flin.mv(m)
	if m.c>80 then
		wo.swb(m,flgd) end
end

function flaw.en(m)
	m.h=90+rnd(6)\1
	wo.v(1,m,m[17] and 1 or -1)
	svh(m,m.h)
end

function flaw.mv(m)
	local x=m[1]
	if x<-20 or x>128 then
		m.dead=true return end
	if m.a~=flt and m[4]==m.h then
		wo.swa(m,flt) wo.v(2,m) end
end

function flgd.en(m,df)
	m.df,m.h=df or 0,100+rnd(6)\1
	wo.v(1,m,m[17] and 1 or -1)
	svh(m,m.h)
end

function flgd.ex(m)
	m.df,m.h=nil
end

function flgd.mv(m)
	ctr(m)
	local y,h,a=m[4],m.h,m.a
	if a==flt then
		if m.df>0 then
			m.df-=1 return end
		if m.rc>1 then
			wo.swb(m,flsk) return end
	end
	if y==119 then
		wo.swb(m,wlgd) return end
	if y==h then
		local x1,x2=m[1],m[3]
		if m[17] then x1,x2=x2,x2+31
		         else x1,x2=x1-31,x1
		end
		if m.df==0 and
		   lnp(m,x1,x2,2) then
			wo.swa(m,hvr)
			wo.v(1,m,m[9],2).v(2,m,1,2)
		elseif a~=flt then
			wo.swa(m,flt)
			wo.v(2,m) m.rc=0
		end
	end
end

function flrf.en(m,df)
	m.df,m.h1,m.h2=df or 0,
	               96+rnd(6)\1,
	               26+rnd(5)\1
	wo.v(1,m,m[1]<64 and 1 or -1)
	svh(m,m.h2)
end

function flrf.ex(m)
	m.df,m.h1,m.h2=nil
end

function flrf.mv(m)
	ctr(m)
	local y,a=m[4],m.a
	if a==gld then
		if y==m.h2 then
			wo.swa(m,flt) wo.v(2,m) end
	elseif a==hvr then
		if y==15 then
			wo.swb(m,wlrf) return
		elseif y==m.h1 then
			wo.swa(m,flt) wo.v(2,m,-1,4)
		elseif y==m.h2 then
			wo.swa(m,flt) wo.v(2,m) end
	elseif y==m.h2 then
		wo.v(2,m)
		if m.df>0 then
			m.df-=1 return end
		if m[3]<35 or m[1]>92 then
			wo.swa(m,hvr) wo.v(2,m,-1)
		end
	end
end

function flsk.en(m,df,pt)
	wo.swa(m,hvr)
	wo.v(1,m,m[17] and 1 or -1)
	  .v(2,m,-1)
	m.df,m.wf=df or 0,pt and
	function(m,w,d,u)
		if d==1 and
		   (w.wl==1 or w.wl==3) then
			return false
		else return fwf(m,w,d,u) end
	end or fwf
end

function flsk.ex(m) m.df=nil end

function flsk.mv(m,w1,w2)
	ctr(m,w1)
	if m.rn>=2 then
		brk(m) return end
	local x1,x2,y=m[1],m[3],m[4]
	if m.df>0 then
		m.df-=1 return end
	local b1,b2,by=lnp(m,x1,x2,2)
	if y==by and b1<=x1
	         and b2>=x2 then
		wo.swb(m,wlgd) return end
	b1,b2,by=lnp(m,x1,x2,5)
	if y==by and b1<x1+5
	         and b2>x2-5 then
		wo.swb(m,wlgd) return end
	if w2 then wo.v(2,m,-1) end
	if m[17] then x1,x2=x1+3,x2
	         else x1,x2=x1,x2-3
	end
	if lnp(m,x1,x2,7) then
		wo.v(2,m,1) end
end

function wlgd.en(m)
	wo.swa(m,wlk)
	wo.v(1,m,m[17] and 1 or -1,4)
	  .v(2,m)
	m.lc,m.pc,m.rc,m.wf=0,0,0,wwf
end

function wlgd.ex(m)
	m.lc,m.pc=nil
end

function wlgd.mv(m,w,p)
	local y,s1,s2=m[4],ctg(m)
	ctr(m,w)
	if m.g>=3600 then
		wo.swb(m,flrf) return end
	if m.sw then
		tof(m,10) m.sw=nil return end
	if w and w.wl==3
	     and not s1 then
		local b=nt(2,w,-1)
		if not b or b[4]==y-8 and
		   not nt(2,b,-1) then
			wo.v(1,m,-m[9],m[11]) tof(m)
		return end
	elseif m.rn>=2 or
	       y==15 and m.rc>0 then
		brk(m,y==15) return end
	local x1,x2,a,d,l=m[1],m[3],m.a
	local px=m[17] and x2-2 or x1+2
	if y==119 then
		d,l,pb=wo[3][2][px\8],2,0.005
	else l,pb=5,0.01 end
	local b1,b2,by=lnp(m,x1,x2,l)
	if y~=by then tof(m) return end
	if b1>=x1+5 or b2<=x2-5 then
		local c1,c2
		if m[17] then c1,c2=b2+1,b2+32
		         else c1,c2=b1-32,b1-1
		end
		if lnp(m,c1,c2,2) then
			wo.swb(m,flsk,0,true) return
		else tof(m,10) return end
	end
	if a==wlk then
		s1,s2=s1 or 0x7fff,
		      s2 or 0x7fff
		if d and d.g>0 and px>d[1]+2
		               and px<d[3]-2
		then wo.swa(m,pck) m.lc=-1
		elseif d and s1<s2
		         and m.pc<0 then
			wo.v(1,m,-m[9],m[11])
			m.pc=60
		elseif rnd()<pb then
			b1,b2=lnp(m,x1,x2,l)
			if b1<=px and b2>=px then
				wo.swa(m,pck) m.lc=20 end
		elseif rnd()<pb then
			wo.swa(m,lkr) m.lc=40 end
	elseif a==pck then
		if p then
			if d and d.g>0 then
				d.g-=1 m.g+=100
			elseif m.lc<0 then
				wo.swa(m,wlk) end
		end
	elseif a==lkr then
		if m.lc<0 then
			wo.swa(m,wlk) end
	end
	m.lc-=1 m.pc-=1
end

function wlrf.en(m)
	wo.swa(m,wlk)
	wo.v(1,m,m[17] and 1 or -1,4)
	  .v(2,m)
	m.rc,m.wf=0,wwf
end

function wlrf.ex(m) m.sc=nil end

function wlrf.mv(m,w)
	ctr(m,w)
	if m.rc==0 then return end
	if m.rc>1 then
		wo.swb(m,flrf,10) return end
	local a=m.a
	if a==wlk then
		local a,i1,i2=wo[1],
		              wo.sk(1,m[5],-1),
		              wo.sk(1,m[7],1)
		for i=i1,i2 do
			if a[i].a==sit then
				return end
		end
		wo.swa(m,sit)
	elseif a==stn then
		m.sc-=1
		if m.sc==0 then
			wo.swb(m,m.g>1800 and flaw
			                   or flgd)
		end
	elseif a==sit and
	       m.g<=1800 then
		wo.swa(m,stn) m.sc=20 end
end

function swpb.en(m)
	wo.swa(m,swp)
	wo.v(1,m,
	     m[1]>127 and -1 or 1,3)
	function m.wf(m,w)
		if w.wl==4 then w.sw=true end
		return true
	end
end

function swpb.mv(m,s)
	if m[1]>130 or m[3]<-3 then
		m.dead=true
		swpb.c=(swpb.c+1)%4
	return end
	if s then
		local u=m[17] and 0 or 1
		local a,j=wo[3][2],m[1]\8+u
		if 1<=j and j<=14 then
			local d=a[j]
			d.g=d.g\(rnd(7)\1+4)
		end
	end
end

function trcb.en(m)
	wo.swa(m,trc) wo.v(1,m,-1,3)
	function m.dr(m)
		local x,y,l=m[1],m[2],m.l
		mdr(m)
		rectfill(x+28,y+1,x+48,y+13,0)
		if l then
			?"level",x+29,y+2,12
			?l.." "..l,x+33,y+8,12
			spr(3,x+37,y+9)
		else
			?"you\f2♥",x+29,y+2,12
			?"win\f9◆",x+29,y+8,12
		end
		spr(240,x-3,y+24)
	end
	function m.wf(m,w)
		return w.wl~=3 or w[4]~=119
	end
end

function trcb.mv(m,w)
	if m[3]<0 then
		m.dead,ov=true,m.l and glv
		                    or gbt
	elseif w then trs(w) end
end
-->8
local function amp(r)
	if not ms[r] then
		mp[#mp+1],ms[r]=r,true end
end

local function ltr(t,u)
	local n=nt(1,t,u)
	if n then
		n=nt(2,n,-1)
		if n then amp(n.r) end
	end
end

local function nmp()
	for i=1,#mp do mp[i]=nil end
	for i in next,ms do
		ms[i]=nil end
	if not p1 then return end
	local a=wo[2]
	for x1=8,104,16 do
		local x2=x1+15
		local i=wo.nx(2,p1[8],1,
		              x1,x2,1,4)
		if not i then goto c end
		local v=a[i]
		if v.mv then
			i=wo.nx(2,i,1,x1,x2,1,4)
			if not i then goto c end
			v=a[i]
		end
		amp(v.r) ltr(v,-1) ltr(v,1)
		local b=a[wo.nx(2,
		   wo.sk(2,wo[3][2][1][6],-1),-1,
		   x1,x2,1,4)]
		if b and not b.mv
		     and b[4]==119 and
		    (not nt(1,b,-1) or
		     not nt(1,b,1)) then
			amp(b.r) end
		::c::
	end
end

local function tdr(t)
	local x,y=t[1],t[2]
	spr(1,x,y,2,1)
	rectfill(x+1,y+2,x+13,y+6,0)
	if t.r then
		local c=0xc
		if t.tm and t.tm\3%2==0 then
				spr(16,x,y,2,1) c=0x8 end
		?t.r,x+(t.r>9 and 4 or 6),y+2,c
	else
		spr(3,x+6,y+3)
		?t.a,x+2,y+2,0xc
		?t.b,x+10,y+2,0xc
	end
end

local function nts(t)
	nmp()
	if #mp>4 and rnd()<0.9 then
		local p=rnd(tm[rnd(mp)])
		t.a,t.b=p[1],p[2]
	else
		t.a,t.b=rnd(lv)\1+1,
		        rnd(lv)\1+1
	end
	t.wl,t.dr=3,tdr
	wo.v(2,wo.add(t),1)
	return t
end

local function spl()
	local y=p3[2]-8
	stp(p1,p2,p3,nts{56,y,71,y+7})
	wo.v(2,p,1,8)
end

local function pmv(t)
	wo.v(1,t)
	local w1,d1,u1,
	      w2,d2,u2=wo.mv(t)
	wo.v(2,t,1,8)
	if d1==2 and not w1.mv or
	   d2==2 and not w2.mv then
		if t[2]==16 then
			if not ov and #md==0 then
				sfx(16) ov=gov end
		return end
		sfx(10)
		mc[#mc+1],t.r,t.mv=t,t.a*t.b
		if lv then spl() end
	end
end

local function pwf(t,w,d,u)
	return w.wl>3
end

local function tmv(t)
	local w=wo.mv(t)
	if w and not w.mv then
		t.mv=nil
		if t[2]>16 then
			sfx(10) mc[#mc+1]=t ml-=1 end
	end
end

local function twf(t,w,d,u)
	return w.wl>3 and w.wl~=8
end

function stp(n,n1,n2,n3)
	p,p1,p2,p3=n,n1,n2,n3
	p.mv,p.wf,p1.mv,p1.wf,p2.mv,
	p2.wf,p3.mv,p3.wf=pmv,pwf,
	tmv,twf,tmv,twf,tmv,twf
end

local function ddr(d)
	spr(25,d[1],d[2])
	local p=d.p
	for i=1,d.g do
		local j=p[i]
		pset(d[1]+j%8,d[2]+j\8,15)
	end
end

local function ndt(i)
	local p,x={},i*8
	for i=1,64 do p[i]=i-1 end
	for i=#p,2,-1 do
		local j=rnd(i)\1+1
		p[i],p[j]=p[j],p[i]
	end
	wo.add{x,120,x+7,127;
	   wl=2,dr=ddr,p=p,g=0}
end

local function gdr(g)
	pset(g[1],g[2],15)
end

local function gmv(g)
	local w,d,u=wo.mv(g)
	if w then
		g.dead=true
		if w.g<64 then w.g+=1 end
		local c=swpb.c
		if w.g>32 and c%2==0 then
			local x=c==0 and 128 or -11
			wo.mob(swpb,6,x,108)
			swpb.c=(c+1)%4
		end
	end
end

local function gwf(g,w,d,u)
	return w.wl~=2
end

local function ngr(x,y)
	local g={x,y,x,y;
	    wl=7,dr=gdr,mv=gmv,wf=gwf}
	wo.add(g)
	wo.v(2,g,1)
end

local function mt(t,r)
	if r then
		md[#md+1],t.tm=t,15 end
	for i=0,3 do
		local n=nt(i%2+1,t,1-i\2*2)
		if n and n.r==t.r then
			r=mt(n,true) end
	end
	return r
end

local function mtch()
	if ml==0 then
		local z=#mc
		for i=1,z do
			if mt(mc[i]) then sfx(11) end
		end
		for i=1,z do mc[i]=nil end
	end
	local j,z=1,#md
	for i=1,z do
		local v=md[i]
		v.tm-=1
		if v.tm==0 then
			v.dead=true
			for i=1,8 do
				ngr(v[1]+gx[i],v[2]+gy[i])
			end
			local n=nt(2,v,-1)
			while n do
				wo.v(2,n,1)
				n.mv=tmv ml+=1
				n=nt(2,n,-1)
			end
		else md[j]=v j+=1 end
	end
	for i=j,z do md[i]=nil end
end

local function bdg(m)
	local g=m.g
	if g~=0 and g~=0x7fff then
		m.g-=1 end
end

local function bird()
	if lv and #ba<bs
	      and bc%bp==1000 then
		local x,y=
		   rnd()<0.5 and -20 or 128,
		   rnd(30)\1+25
		local m=wo.mob(flin,4,x,y)
		m.g,m.dg=1000,bdg
	end
	bc+=1
end
-->8
local hd,hs,hn,dbg

local function nbs(bs)
	if bs==0 then bs=3 end
	if bs>=2 and bs<=5 then
		dset(1,bs)
		menuitem(2,"flock size: "..bs,
		         mbs)
		return bs
	end
end

function mbs(b)
	local bs=nbs(dget(1))
	if b&1~=0 then
		nbs(bs-1) return true end
	if b&2~=0 then
		nbs(bs+1) return true end
end

local function nlv(lv)
	if lv==0 then lv=3 end
	if lv>=3 and lv<=9 then
		dset(0,lv)
		menuitem(1,"start level "..
		         lv.."X"..lv,mlv)
		return lv
	end
end

local function slv()
	music(-1)
	swpb.c,lv,bs,hd,ov=0,dget(0),
	                     dget(1)
	bc,bp,tm=0,5400*(lv/9)\1,{}
	for i=1,lv do
		for j=1,lv do
			local r=i*j
			local m=tm[r] or {}
			m[#m+1],tm[r]={i,j},m
		end
	end
end

function mlv(b)
	local lv=nlv(dget(0))
	if b&1~=0 then
		nlv(lv-1) return true end
	if b&2~=0 then
		nlv(lv+1) return true end
	wo[1],wo[2],wo[3]={},{},{}
	wo.map(0,0,0,0,16,16)
	wo.add{56,24,56,24;wl=8}
	ba,ml,mc,md,mp,ms,tm,wn,gx,gy,
	                p,p1,p2,p3=
   wo[3][4],0,{},{},{},{},{},{},
   {0,0,2,4,8,11,14,15},
   {3,6,0,0,0,0,2,4}
	for i=1,14 do ndt(i) end
	slv()
	stp(nts{56,16,71,23},
	    nts{56,8,71,15},
	    nts{56,0,71,7},
	    nts{56,-8,71,-1})
end

local function chlv()
	if lv then
		local c=0
		for i=1,#ba do
			if ba[i].a==sit then c+=1 end
		end
		if c==bs then
			music(0)
			wo.mob(trcb,5,128,88).l=
			                   nlv(lv+1)
			md[#md+1],p.tm,lv=p,1
			for i=1,#ba do
				ba[i].g=0x7fff end
		end
	elseif #wo[3][5]==0 and
	            btnp(2) then
		slv() spl()
		for i=1,#ba do
			local b=ba[i]
			wo.swa(b,stn) b.sc=20
		end
	end
end

local function hwl()
	map()
	?"hi, friend!",44,34,14
	?"ready to play?",38,40
	?"  \fcmultiply numbers,\n\f4match falling bricks,",25,50
	?"and feed hungry pigeons\n    on your rooftop.",19,62,15
	?"be quick, be smart,",28,78,14
	?"the birds are waiting!",22,84
	?"\fcMULTIPLY,\f4MATCH,\ffFEED!",41,105
	if hd==hwl then
		?"press ➡️\nfor help",88,1,13
		?"press ⬆️\nto start",9,1,13
	end
	spr(28,56,0,2,3)
	spr(192,8,112,14,2)
	mdr{96,22;a=flt,i=2}
	mdr{26,99;[17]=true,a=wlk,i=4}
end

local function htt()
	?"⬆️play",0,0,13
	for i=0,9 do
		for j=0,9 do
			?i.."X"..j.."="..i*j,i%5*26,7+i\5*62+j*6,6
		end
	end
end

local function hct()
	?"⬆️play",0,0,13
	?"developer contacts:",0,32,3
	?"inbox\f8@\f3oldygames.com",9,48,3
	?"github.com\f8/\f3oldygames",9,64,3
	?"lexaloffle.com\f8/\f3bbs\f8/\f3?uid=137270",9,80,3
	?"copyright 2026    oldygames",0,122,13
	spr(18,0,46)
	spr(18,0,62)
	spr(18,0,78)
	spr(18,60,120)
end

local function brs()
	tdr{8,112;r=12}
	tdr{56,112;r=10}
	tdr{56,104;r=9}
	tdr{88,112;r=2}
end

local function hs1() hwl() end

local function hs2()
	spr(245,60,35)
	spr(60,56,52,2,1)
	spr(26,24,112,2,1)
	?"a brick\nfalls with\n\fca problem",77,30,6
	?"      ⬅️  ⬇️  ➡️\n\nmove it \f9left\f6 or \f9right\f6,\npress \f9down\f6 to drop fast",20,65,6
	?"when it lands,\nit shows \fcthe answer",43,107,6
end

local function hs3()
	?"\fcsame numbers \fapop,\n   \ffseeds drop!",31,31,6
	?"\famore\f6 bricks pop,\n\ffmore\f6 seeds drop.",34,53,6
	?"\faside by side\f6 counts.\n   corners don't.",30,75,6
	?"seeds from bricks",49,122,15
	tdr{24,112;r=12}
	tdr{40,112;r=8}
	tdr{40,104;r=12,tm=0}
	tdr{56,112;r=12,tm=0}
	tdr{56,104;r=12,tm=0}
	tdr{72,112;r=8}
	tdr{72,104;r=4}
	tdr{72,96;r=12}
	spr(243,21,75)
	spr(244,35,81)
	spr(244,22,110)
	spr(244,70,94)
	spr(249,24,120,3,1)
	mdr{95,107;a=lkr,i=2}
end

local function hs4()
	?"     \f9a new pigeon\f6\nflies in now and then.",21,37,6
	?"\fffeed it\f6 and it stays!",23,58,6
	?"it needs enough room",24,73,6
	?"to land on the ground:\n\fb2 bricks wide or more\f6.",22,79,6
	spr(224,8,120,14,1)
	spr(243,28,117)
	spr(244,78,117)
	spr(244,109,117)
	brs()
	mdr{15,24;[17]=true,a=flt,i=2}
	mdr{36,107;a=wlk,i=4}
end

local function hs5()
	?"\fbfed pigeons\f6 fly up\n  to your rooftop.",42,28,6
	?"\f9hungry again?\f6\nback to the ground\nfor \ffseeds\f6!",18,46,6
	?"\f8hungry too long?\f6\nit flies away. \febye-bye!",23,70,6
	?"pop bricks, make room -\n\fafeed your birds in time!",17,89,6
	spr(224,8,120,14,1)
	spr(246,16,29) spr(246,28,29)
	brs()
	mdr{15,3;a=sit,i=2}
	mdr{27,3;a=sit,i=2}
	mdr{95,50;a=gld,i=1}
	mdr{-2,66;a=flt,i=2}
	mdr{32,110;a=pck,i=2}
end

local function hs6()
	?"\fftoo many seeds\f6 in one spot\n calls \fea man with a broom\f6.",13,33,6
	?"he sweeps almost all seeds.",12,57,6
	?" keep seeds \f9spread out\f6\nto save them for birds!",19,75,6
	spr(224,8,120,9,1)
	spr(252,40,120,2,1)
	spr(250,8,120,2,1)
	spr(249,16,120,3,1)
	spr(250,56,120,2,1)
	spr(248,45,110) spr(247,77,97)
	pset(94,123,15)
	pset(104,125,15)
	pset(111,121,15)
	brs()
	mdr{77,108;a=swp,i=2}
end

local function hs7()
	local bs=dget(1)
	?"get \fb"..bs.." pigeons",39,29,6
	?"on the rooftop",37,35,6
	?"\fbto beat\f6 the level.",31,41,6
	?"   too easy or too hard?\nset \f9flock size\f6 in settings.\n  more birds,harder game.",12,54,6
	?" levels go from \fc3X3\f6 to \fc9X9\f6\nor pick \f9a level\f6 in settings.",10,80,6
	?"big numbers,big challenge!",14,92,6
	?"enjoy the game!",36,106,14
	spr(246,20,29) spr(246,102,29)
	for i=1,bs do
		if i>3 then i+=4 end
		mdr{i*12-5,3;a=sit,i=2}
	end
	mdr{14,107;[17]=true,a=wlk,i=4}
	spr(46,102,104,2,2)
end

hs={hs1,hs2,hs3,hs4,hs5,hs6,hs7}

local function hlp()
	map()
	spr(28,56,0,2,3)
	spr(208,8,120,14,1)
	if hn>1 then
		?"⬅️prev",0,0,13
	end
	if hn<#hs then
		?"next➡️",105,0,13
		?"play⬆️",105,7,13
	else
		?"play⬆️",105,0,13
	end
	hs[hn]()
end

local function _init()
	cartdata("aribrix")
	menuitem(3,"times table",
		function() hd=htt end)
	menuitem(4,"how to play",
		function()
			hd,hn=hlp,hd==hwl and 2 or 1
			if not stat(57) then
				music(0) end
		end)
	menuitem(5,"contacts",
		function() hd=hct end)
	mbs(0) mlv(0) music(0) hd=hwl
end

local function _update()
	if hd then
		if hd==hwl and btnp(1) then
			hd,hn=hlp,2 return end
		if hd==hlp then
			if hn>1 and btnp(0) then
				hn-=1 end
			if hn<#hs and btnp(1) then
				hn+=1 end
		end
		if btnp(2) then
			hd,hn=nil
			if lv then music(-1) end
		end
	return end
	if lv then
		if p[2]>=0 then
			if btnp(0) then
				wo.v(1,p,-16).mv(p) end
			if btnp(1) then
				wo.v(1,p,16).mv(p) end
		end
		if btn(3) then
			wo.v(2,p,8) end
	end
	if btnp(4) and btnp(5) then
		dbg=not dbg end
	mtch()
	bird()
	wo.all("dg",0x8)
	wo.all("mv",0x7c)
	wo.prg(0x7c)
	chlv()
end

local function pdbg()
	local a=wo[3]
	for i=1,#a do
		?i.." "..#a[i],0,i*7-7,8
	end
	for i=1,#ba do
		?ba[i].g,109,i*7-7,8
	end
	for i=1,#mp do
		local j=i-1
		?mp[i].." ",11+j%10*11,56+j\10*6,8
	end
end

local function _draw()
	cls()
	if hd then hd() return end
	map()
	wo.all("dr")
	if ov then ov() end
	if dbg then pdbg() end
end
__gfx__
0000000000f4f444f44f4440c0c00000000044000000000033333333333333333333333355555555333333335555555533555533666666667777ff44ff444477
0000000004444444444444440c00000000004a400000000033333333333333335555555533333333333333333333333333333333030330307777ff44ff444477
0000000040000000000000f4c0c0000000004a400000000036666663366666635666666533366333333663333333333333333333555555557744444444444444
00000000f0000000000000440000000000004aa40000000036a6aa63360600635633336533655633336556333333333333333333333333337744444444444444
00000000400000000000004f00000000000004a40000000036a6aa63360600633633336336500563365005633333333333333333333663334400cccc0000ff44
00000000400000000000004400000000044444aa4000000036a6aa63360600633633336333500533335005333333333333333333336556334400cccc0000ff44
00000000f000000000000040000000004aaaa4aaa400000036a6aa6336060063363333633355553333555533333333333333333336500563ff0000cc00004444
000000000444444444444400000000004444444aaa40000036a6aa6336060063363333633333333333333333333333333333333333500533ff0000cc00004444
00fafaaafaafaaa0888aa888000000004aaaaa4aaaa0000036a6aa6336060063360333635555555500f4f444f44f444000f4f444f44f4440440000cc000044ff
0aaaaaaaaaaaaaaa8aaaaaa8000000000444444aaaa000003666666336666663363333630550550504444444444444440444444444444444440000cc000044ff
a0000000000000fa800000080000000004aaaa4aaaa00000377777733777777336333363500550504000cc00ccc000f440ccc00000ccc0f4440000cc00004444
f0000000000000aaa00aa00a000000000444444aaaa0000033333333333333333633336355505500f0000c0000c00044f000c0c0c000c044440000cc00004444
a0000000000000afaaaaaaaa00000000004aa4aaa44000003333333333333333363333630505005540000c00ccc0004f40ccc00c00ccc04fff00cccccc004477
a0000000000000aa8a0aa0a80000000000044444400000003333333333333333363333635505550540000c00c000004440c000c0c0c00044ff00cccccc004477
f0000000000000a08aa00aa800000000000000000000000033333333333333333633336350500500f000ccc0ccc00040f0ccc00000ccc0407744444444447777
0aaaaaaaaaaaaa00888aa88800000000000000000000000033333333333333333633336305005050044444444444440004444444444444007744444444447777
00055500000000000005500000000000005500000000000000005500000000000000000000000000000000000000000000f4f444f44f44400000000000000000
00095900000000000059550000000000059550000000000000059550000000000000000000000000000000000055556604444444444444440022220000000000
00055500000000000555555000000000555555000000000000555555000000000000006656555500000000056555566040cc000000ccc0f40222220000000000
000d5d660000000000005d66000000000005dd6600000000000005d60000000000006666566556660000066556555600f00c00c0c0c00044005f5f0000000000
000ddd6666000000000ddd6666000000000dd666660000000000dd66660000000555d666556656000000666656656000400c000c00ccc04ff0ffff0000000000
0000d66666500000000dd666665000000000d666665000000000d666665000000595dd6665656000000dd66655650000400c00c0c000c0441055f00000000000
000066666565000000006666656500000000666665650000000066666565000000550d66655500000555dd6665500000f0ccc00000ccc0401002200060000000
000006655655500000000665565550000000066556555000000006655655500000500066550000000595dd665500000004444444444444001122221060000000
00000555665555000000055566555500000005556655550000000555665555000000000808000000005500080800000000f4f444f44f444000222210f0000000
00000056655655500000005665565550000000566556555000000056655655500000008080800000005000808080000004444444444444440022220160000000
00000005056666000000000505666600000000050566660000000005056666000000000000000000000000000000000040c0c00000ccc0f40011110060000000
000000080800066600000000800006660000000808000666000000080800066600000000000000000000000000000000f0c0c0c0c000c0440002200060000000
00000080808000000000000808000000000000808080000000000080808000000000000000000000000000000000000040ccc00c000cc04f0020020060000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000c0c0c000c0440020020606000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000c00000ccc0400010010606000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444444444000110116060600000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000006666000000
00000000550000000000000000000000000000000000000000000000000000000000000000000000000556500000000000000000000000000056666600000000
00000005565000000000000000000000000000000000000000000000000000000000000000000000005665500000000000000000000000055565566000000000
00000005665000000000000000000000000000000000000000000000000000000000000000550000056655000055000000000000000005565655660000000000
00000005656500000000000000000000000000000000000000000000000000000000000005955000566565000595500000000000000006555566600000000000
000000565655000000000000000000000000000000000000000000000000000000000000555555056656550055555500000000000055d6666666000000000000
0000005665650000000000000000000000000000000000000000000000000000000000000005dd56656550000005d555000000000595dd666668800000000000
005500556655500000000000005500055555000000000000005500055555000000000000000dd6555655500055555666500000000555dd666000000000000000
05955dd6555566550000000005955dd5565556550000000005955d5556566655000000000000d665555500000566656565000000500000000000000000000000
5555dd6666666666666600005555dd5565656666666600005555dd65656666666666000000006666656000000056665655600000000000000000000000000000
00005d66666666655000000000005d55565566655000000000005d66566666655000000000000666665500000005556556550000000000000000000000000000
00000066666666000000000000000055655566000000000000000066666666000000000000000666666550000000555566655000000000000000000000000000
00000006666600000000000000000005565600000000000000000006666600000000000000000066666650000000006666665000000000000000000000000000
00000000000880000000000000000005555880000000000000000000000880000000000000000005056566000000000505656600000000000000000000000000
00000000000000000000000000000000550000000000000000000000000000000000000000000080800006660000008080000666000000000000000000000000
00000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222200000000000022220000000000002222000000000000222200000000000005550000000000000000000000000000000000000000000000000000000000
02222200000000000222220000000000022222000000000002222200000000000009590000000000000000000000000000000000000000000000000000000000
00f5ff000000000000f5ff000000000000f5ff000000000000f5ff00000000000005550000000000000000000000000000000000000000000000002222000000
0fffff00000000000fffff00000000000fffff00000000000fffff0000000000006d5d6000000000000000000000000000000000000000000000022222000000
005ff00000000000005ff00000000000005ff00000000000005ff00000000000056ddd6500000000000555000000000000055500000000000000065f5f000000
60022000000000006002200000000000000220000000000000022000000000000566d6650000000000095900000000000005550000000000000006ffff000000
112122000000000010212200000000006021220000000000002122000000000005666665000000000005550000000000000555000000000000000655f0000000
60212200000000000621220000000000012122000000000000221200000000000556665500000000506d5d6050000000506d5d605000000000000f0220000000
01122200000000000612220000000000006122000000000061621200000000000055655000000000566ddd6650000000566ddd66500000000000062222100000
061111000000000000111100000000000016110000000000001616600660000000655560000000005666d666500000005666d666500000000000062222010000
06022000000000000062200000000000000260000000000000022006660000000005650000000000556666655000000055666665500000000000062222100000
0060020000000000000620000000000000200666600000000002200060600000000808000000000005566655000000000556665500000000000060611f000000
06660200000000000006600000000000002006606000000000022000060000000080808000000000005555500000000000555550000000000000606220000000
06160100000000000006160000000000001006060000000000011000006000000000000000000000000000000000000000000000000000000006062602000000
61606100000000000061606000000000011016600000000000111000000000000000000000000000000000000000000000000000000000000000001001000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011011000000
00000000000000000000000000044444444444444444444444000000000000000000000000000000000444444444444444444444440000000000044444400000
000000000000000000000000000400000000000000000000040000000000000000000000000000000004000000000000000000000400000000044aaaaaa44000
0000000000000000000000000004000000000000000000000400000000000000000000000000000000040000000000000000000004000000004aaaaaaaaaa400
000000000000000000000000000400000000000000000000040000000000000000000000000000000004000000000000000000000400000004aaaaaaaaaaaa40
00000000000000000000000000040000000000000000000004000000000000000000000000000000000400000000000000000000040000000000000000000000
00000000006000000000000000040000000000000000000004000000000000000600000000000000000400000000000000000000040000004000070000007004
00000000000000000000000000040000000000000000000004000000000000006000000000000000000400000000000000000000040000004a00700aa00700a4
00000006060000000000000000040000000000000000000004000000000000000060000000000000000400000000000000000000040000004aa000aaaa000aa4
0000000000600000009a000000040000000000000000000004000000000000060000000000a90000000400000000000000000000040000004aaaaaaaaaaaaaa4
0000000060000000009a000000040000000000000000000004000000000000000060000000a90000000400000000000000000000040000004aaaaaaaaaaaaaa4
00000000060000011111111110040000000000000000000004000000000000000600000111111111100400000000000000000000040000004aaa0aaaaaa0aaa4
000000000000000070000000700400000000000000000000040000000000000000000000700000007004000000000000000000000400000004aaa0aaaa0aaa40
000000000500000070022220700400000000000000000000040000000000000005000000700222207004000000000000000000000400000004aaaa0000aaaa40
0000000005000007002222207004000000000000000000000400000000000000050000070022222070040000000000000000000004000000004aaaaaaaaaa400
0000000005000007000f5ff0700444444444444444444444440000000000000005000007000f5ff07004444444444444444444444400000000044aaaaaa44000
000000000500000700fffff070040000000000000000000000000000000000000500000700fffff0700400000000000000000000000000000000044444400000
00000000050000700005ff007004000000000000000000000000000000000000050000700005ff00700400000000000000000000000000000000444000000000
00000000050000750000220070040000000000000000000000000000000000000500007500002200700400000000000000000000000000000004aaa400000000
0000000005000070500212207004000000000000000000000000000000000000050000705002122070040000000000000000000000000000004aa44400000000
0000000005000705051112207004000000000000000000000000000000000000050007050511122070040000000000000000000000000000004aaaa400000000
0001111155511750005555555004000000000000000000000000000000011111555117500055555550040000000000000000000000000000004a444000000000
0011111111111111115111111584000000000000000000000000000000111111111111111151111115840000000000000000000000000000044a400000000000
0011a555555511111511666611a400000000000000000000000000000011d555555511111511666611d4000000000000000000000000000004aa400000000000
d0111111111151115166666666140000000000000000000000000000d011111111115111516666666614000000000000000000000000000004aa440044444000
d0011116666115115166666666140000000000000000000000000000d001111666611511516666666614000000000000000000000000000004aaa404aaaaa400
d0011166666611551666611666640000000000000000000000000000d001116666661155166661166664000000000000000000000000000044aaa44aaaaaaa40
d00016661166611116661d5166600000000000000000000000000000d000166611666111166615d1666000000000000000000000000000004aaaa4aaaaaaaaa4
dddd1661d5166155166615d166600000000000000000000000000000dddd16615d16615516661d51666000000000000000000000000000004aaa4aa4aaaa4aaa
ddddd6615d1660000666611666600000000000000000000000000000ddddd661d516600006666116666000000000000000000000000000004aaaaaaa4444aaaa
d0000666116660000066666666000000000000000000000000000000d000066611666000006666666600000000000000000000000000000004aaaaaaaaaaaaa4
d0000066666600000066666666000000000000000000000000000000d00000666666000000666666660000000000000000000000000000000044444aaaaaa440
d0000006666000000000666600000000000000000000000000000000d00000066660000000006666000000000000000000000000000000000000000444444000
00f4f444f44f444000f4f444f44f444000f4f444f44f444000f4f444f44f444000f4f444f44f444000f4f444f44f444000f4f444f44f44400000000000000000
04444444444444440444444444444444044444444444444404444444444444440444444444444444044444444444444404444444444444440060002222000000
400000ccc00000f4400000ccc00000f4400000ccc00000f4400000ccc00000f4400000ccc00000f4400000ccc00000f4400000c0c00000f40060022222000000
f00000c0c0000044f00000c0c0000044f000000c00000044f00000c0c0000044f00000c0c0000044f000000c00000044f00000c0c00000440060005f5f000000
400000ccc000004f400000cc0000004f4000000c0000004f400000cc0000004f400000cc0000004f4000000c0000004f4000000c0000004f00f000ffff000f00
400000c0c0000044400000c0c00000444000000c00000044400000c0c0000044400000c0c00000444000000c00000044400000c0c000004400610055f0001000
f00000c0c0000040f00000c0c0000040f00000ccc0000040f00000ccc0000040f00000c0c0000040f00000ccc0000040f00000c0c00000400060100220010000
04444444444444000444444444444400044444444444440004444444444444000444444444444400044444444444440004444444444444000060012222100000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555550606002222000000
05505505055055050550550505505505055055050550550505505505055055050550550505505505055055050550550505505505055055050606002222000000
50055050500550505005505050055050500550505005505050055050500550505005505050055050500550505005505050055050500550506060601111000000
55505500555055005550550055505500555055005550550055505500555055005550550055505500555055005550550055505500555055000000000220000000
05050055050500550505005505050055050500550505005505050055050500550505005505050055050500550505005505050055050500550000002002000000
55055505550555055505550555055505550555055505550555055505550555055505550555055505550555055505550555055505550555050000002002211000
50500500505005005050050050500500505005005050050050500500505005005050050050500500505005005050050050500500505005000000001000001000
05005050050050500500505005005050050050500500505005005050050050500500505005005050050050500500505005005050050050500000011000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000f00000000f00000000000000000000000f000000000000000000f000000000000000f00000000000000000f0000000000000000002222000000
00000f00000000000f0000000000f00000f000000000f00000f000000f0000000000000000000f00000000000f00000000000000000000000000022222000000
00000000000f0000000f00000f00000000000000f00000000000f0000000000000000f0000000000000f0000000000000f000000000000000000005f5f000000
000000000f00000000000f000000000000000f000000000000000000000f000000f0000000000000f0000000000000f00000f00000000000000000ffff000f00
0f00000000000000f000000000000f000000000000f000000f0000f000000f0000000000000f0000000000f000f000000000000000f0000000000055f0001000
000000000000f000000f0000000000000f000000000000f000000000000000000000f000000000f000f000000000000000000f00000000000060000220010000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060012222100000
000000000880880000000000000000b0800080000006000000060000000e000000000000000000000000f000000f0000f0f0fff0f0f0f00f0060102222000000
00000000888888800000000000000b00080800000006000000666000000e0000000900000000f00000f0000f000000000f0f00ff0f0f0ff000f1002222000000
00d000008888888000000000b000b000008000000006000006666600000e0000009990000000000000000f00000f00f000f0f0f0ffff0f0f0060001111000000
00d0000008888800000000000b0b0000080800000006000000060000000e000000909000000000f0000f000000f00000fff0ff0ff0f0ff0f0060000220000000
00d00000008880000000000000b00000800080000006000000060000000e0000099099000f000000f000000f0000f000f0ff0ff0f0fff0f00060122002000000
0dd000000008000000000000000000000000000006666600000600000eeeee000999990000000f0000000f000f00000f0f00f0ff0f00f0f00606100002000000
0dd0000000000000000000000000000000000000006660000006000000eee00099909990000000000f00000000000f00f0ff0ff0ffff0f0f0606000001000000
ddd00000000000000000000000000000000000000006000000060000000e00009999999000000000000000000000f0000f00f00ff0f0f0f06060600011000000
__label__
0000000000000000000000000000000000000000000000006666666600f4f444f44f444066666666000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000003033030044444444444444403033030000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000005555555540ccc00000ccc0f455555555000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000033333333f0c0c0c0c000c04433333333000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000003336633340ccc00c000cc04f33366333000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000336556334000c0c0c000c04433655633000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000036500563f000c00000ccc04036500563000000000000000000000000000000000000000000000000
00000000000000000000000000055500000000055500000033500533044444444444440033500533000000000000000000000000000000000000000555000000
0000000000000000000000000009590000000009590000003355553300f4f444f44f444033555533000000000000000000000000000000000000000959000000
00000000000000000000000000055500000000055500000033333333044444444444444433333333000000000000000000000000000000000000000555000000
000000000000000000000000506d5d605000506d5d6050003333333340ccc00000ccc0f433333333000000000000000000000000000000000000506d5d605000
000000000000000000000000566ddd665000566ddd66500033333333f000c0c0c000c04433333333000000000000000000000000000000000000566ddd665000
0000000000000000000000005666d66650005666d666500033333333400cc00c000cc04f333333330000000000000000000000000000000000005666d6665000
000000000000000000000000556666655000556666655000333333334000c0c0c000c04433333333000000000000000000000000000000000000556666655000
00000000000000000000000005566655000005566655000033333333f0ccc00000ccc04033333333000000000000000000000000000000000000055666550000
00000000000000000000000000555550000000555550000033333333044444444444440033333333000000000000000000000000000000000000005555500000
5555555555555555555555555555555555555555555555553333333300f4f444f44f444033333333555555555555555555555555555555555555555555555555
33333333333333333333333333333333333333333333333333333333044444444444444433333333333333333333333333333333333333333333333333333333
3336633333333333333663333333333333366333333333333336633340ccc00000ccc0f433366333333333333336633333333333333663333333333333366333
33655633333333333365563333333333336556333333333333655633f0c0c0c0c0c0c04433655633333333333365563333333333336556333333333333655633
3650056333333333365005633333333336500563333333333650056340ccc00c00ccc04f36500563333333333650056333333333365005633333333336500563
335005333333333333500533333333333350053333333333335005334000c0c0c000c04433500533333333333350053333333333335005333333333333500533
33555533333333333355553333333333335555333333333333555533f000c0000000c04033555533333333333355553333333333335555333333333333555533
33333333333333333333333333333333333333333333333333333333044444444444440033333333333333333333333333333333333333333333333333333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
36666663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036666663
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36666663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036666663
37777773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000037777773
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
36666663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036666663
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36666663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036666663
37777773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000037777773
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
3333333300000000000000000000000000000000000000000000000000f4f444f44f444000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000044444444444444400000000000000000000000000000000000000000000000033333333
3333333300000000000000000000000000000000000000000000000040ccc00000ccc0f400000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000f0c0c0c0c000c04400000000000000000000000000000000000000000000000033333333
3333333300000000000000000000000000000000000000000000000040ccc00c000cc04f00000000000000000000000000000000000000000000000033333333
333333330000000000000000000000000000000000000000000000004000c0c0c000c04400000000000000000000000000000000000000000000000033333333
36666663000000000000000000000000000000000000000000000000f000c00000ccc04000000000000000000000000000000000000000000000000036666663
36060063000000000000000000000000000000000000000000000000044444444444440000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36666663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036666663
37777773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000037777773
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
36666663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036666663
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
3606006300f4f444f44f444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36666663044444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036666663
377777734000cc00ccc000f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000037777773
33333333f0000c00c000004400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
3333333340000c00ccc0004f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
3333333340000c0000c0004400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333f000ccc0ccc0004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333044444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
3333333300f4f444f44f444000f4f444f44f44400000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
33333333044444444444444404444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000033333333
366666634000ccc0cc0000f44000ccc0ccc000f40000000000000000000000000000000000000000000000000000000000000000000000000000000036666663
36060063f000c0c00c000044f00000c000c000440000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
360600634000ccc00c00004f40000cc0ccc0004f0000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
360600634000c0c00c000044400000c0c00000440000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063f000ccc0ccc00040f000ccc0ccc000400000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
36060063044444444444440004444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000036060063
3606006300f4f444f44f444000f4f444f44f4440000000000000000000000000000000000000000000000000000000000000000000f4f444f44f444036060063
36666663044444444444444404444444444444440000000000000000000000000000000000000000000000000000000000000000044444444444444436666663
377777734000cc00ccc000f44000c0c0ccc000f400000000000000000000000000000000000000000000000000000000000000004000cc00ccc000f437777773
33333333f0000c00c0000044f000c0c0c00000440000000000000000000000000000000000000000000000000000000000000000f0000c00c0c0004433333333
3333333340000c00ccc0004f4000ccc0ccc0004f000000000000000000000000000000000000000000000000000000000000000040000c00ccc0004f33333333
3333333340000c0000c00044400000c000c00044000000000000000000000000000000000000000000000000000000000000000040000c00c0c0004433333333
33333333f000ccc0ccc00040f00000c0ccc000400000000000000000000000000000000000000000000000000000000000000000f000ccc0ccc0004033333333
33333333044444444444440004444444444444000000000000000000000000000000000000000000000000000000000000000000044444444444440033333333
3333333300f4f444f44f444000f4f444f44f4440000000000000000000000000000000000000000000000000000000000000000000f4f444f44f444033333333
55555555044444444444444404444444444444440000000000000000000000000000000000000000000000000000000000000000044444444444444455555555
566666654000cc00ccc000f4400000ccc00000f400000000000000000000000000000000000000000000000000000000000000004000ccc0ccc000f456666665
56333365f0000c00c0c00044f00000c0c00000440000000000000000000000000005500000000000000000000000000000000000f00000c000c0004456333365
3633336340000c00c0c0004f400000ccc000004f00000000000000000000000000595500000000000000000000000000000000004000ccc000c0004f36333363
3633336340000c00c0c00044400000c0c000004400000000000000000000000005555550000000000000000000000000000000004000c00000c0004436333363
36333363f000ccc0ccc00040f00000ccc000004000000000000000000000000000005d6000000000000000000000000000000000f000ccc000c0004036333363
3633336304444444444444000444444444444400000000000000000000000000000dd66660000000000000000000000000000000044444444444440036333363
3603336300f4f444f44f444000f4f444f44f4440000000000000000000000000000d6666650000000000000000f4f444f44f444000f4f444f44f444036033363
36333363044444444444444404444444444444440000000000000000000000000006666656500000000000000444444444444444044444444444444436333363
363333634000ccc0ccc000f44000ccc0ccc000f40000000000000000000000000000665565550000000000004000c0c0ccc000f4400000ccc00000f436333363
36333363f00000c000c00044f00000c0c0c00044000000000000000000000000000055566555500000000000f000c0c0c0c00044f00000c00000004436333363
363333634000ccc000c0004f40000cc0c0c0004f0000000000000000000000000000056655655500000000004000ccc0ccc0004f400000ccc000004f36333363
363333634000c00000c00044400000c0c0c00044000000000000000000000000000000505666600000000000400000c000c0004440000000c000004436333363
36333363f000ccc000c00040f000ccc0ccc00040000000000000000000000000000000808000666000000000f00000c000c00040f00000ccc000004036333363
36333363044444444444440004444444444444000000000000000000000000000000080808000000000000000444444444444400044444444444440036333363
55555555555555555f55555f55f5ffff555555f5555f5555555555555555555555555555555555555555555f5555555555555555555555555555555555555555
05505505f5505505055055f5f5f055050ff0550505505505055055050550550f0550550505505505f550550f05505505055055f50550550505f0550505505505
500550505ff55050500f5050500550f0ff055f5f50055050500f505050055050500550505005505050055050500550505005505050055050500550f050055050
555055005550550055505f0ff5f055005ffff5005550550f55505f00555055ff55505500555055005550550055f055005550f5005550f5005550550055505500
0505005505f5f05505050055050ff05f05050fff0505f05505050055050500f50505005505050055050f005505f5005505050055050500550505005505050055
5505550555f555055505f5055505550555ff5f0555f55505550555055f055505550555055505550555f555055f05550f55055505ff0555055505550555055505
505005005ff005005050050050ffffff50ff050f50500500505f0500505005f050500500505005005f5005ff5050050050f00500505f05005050050050500500
0500505005f05050050050500f0ff050f500505f0500505005f050500500ff500500505005005050050050500500505005005f50050050500f00f05005005050

__map__
0000000000000d00000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c00000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090b090b090b0a00000a0b090b090b0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1700000000000000000000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1700000000000000000000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1700000000000000000000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1700000000000000000000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1700000000000000000000000000001700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0800000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1900000000000000000000000000001900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0514000009173000032d633000030417300003286332863307173000032b633000030217300003266332663304173000032863300003041730000328633286330017300003246332460300173000032463324603
011400000917009170000000000004170041700000000000071700717000000000000217002170000000000004170041700910000000041700410002170021000017000170001000210002170001000417000000
011400001c070000001c070000001d070000001c0701a0701a0701a07000000000001c070000001a07000000180701800018070000001c070000001a0701807018070180701a0001a07018070000001a07000000
0114040018070000001a070000001c000000001c000000001d000000001c000000001a0001a00000000000001c000000001a00000000180001800018000000001c000000001a0000000018000180000000000000
011400001c0711c0711d0001c00018072180001707218072130721a072150721807218072000001a0701a0711c0711c0701d0001c00018072180001707218072130721a072150721307213072000001a0701a071
011400000917009170000000000004170041700000000000071700717000000000000217002170000000000004170041700910000000041700410002170021000017000100001700210002170001000417000000
011400001c070000001c070000001d070000001c0701a0701a0701a07000000000001c070000001a0700000018070180001f070000001c07000000230702407024070240701a0001a00018000000001a00000000
011400001c0711c0711d0001c00018072180001707218072130721a072150721807218072000001a0701a0711c0711c0701d0001c0001807218000170721807213072180721c0711f0712407100000180701a070
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000106731860300603016030260305603096030d603166031c6032060325603296032c6032f60331603346033660337603376033760336603316031e6030060300603006030060300603006030060300603
01080000180751c0751f075240752407524075240751300513005130051300513005130051b0051f0052600502005060050800510005170051b005230052d005390053f005000050000500005000050000500005
911900001865400604006040060400604006040060400604006040060400604006040060400604006040060400604000000000000000000000000000000000000000000000000000000000000000000000000000
910200001525300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
010100000c17300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
011900003c62400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604
951000001815017150161501515014150141501415000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 40414303
01 40000102
00 40000102
00 40000102
00 40000506
00 40000104
02 40000107
00 40414444
00 40414744
00 40414244
00 40414244

