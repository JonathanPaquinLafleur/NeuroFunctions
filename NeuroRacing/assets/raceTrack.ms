
	convertToSplineShape $trajectory
	k     = numKnots $trajectory
	knots = k as String
	
	str = ""
	
	for i = 1 to k do
	(
		knot = getKnotPoint $trajectory 1 i
		x    = knot.x as String
		y    = knot.y as String
		z    = knot.z as String
	  
		controlPoint1 = getOutVec $trajectory 1 i	
		c1x = controlPoint1.x as String
		c1y = controlPoint1.y as String
		c1z = controlPoint1.z as String
		
		if (i == k) do(
			i = 0
		)
		
		controlPoint2 = getInVec $trajectory 1 (i+1)	
		c2x = controlPoint2.x as String
		c2y = controlPoint2.y as String
		c2z = controlPoint2.z as String
	
		knot = getKnotPoint $trajectory 1 (i+1)
		endx    = knot.x as String
		endy    = knot.y as String
		endz    = knot.z as String
		
	 str += ("{x:"+x+",y:"+y+",z:"+z+",c1x:"+c1x+",c1y:"+c1y+",c1z:"+c1z+",c2x:"+c2x+",c2y:"+c2y+",c2z:"+c2z+",endx:"+endx+",endy:"+endy+",endz:"+endz+"},")
	)
	print str