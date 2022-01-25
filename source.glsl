/*****
 *
 * Very base example on how to raytrace sphere.Based on extremely beautiful and simple 
 * shader and relative tutorial by kig. The purpose of this shader is not to be 
 * as small as possibile but to write clear code useful for understand the math behind-the-scene.
 *
 *****/

// colors
const vec3 skyColor = vec3( 0.4, 0.2, 1.0 );
const vec3 sunColor = vec3(2.0, 2.0, 0.5); // vec3( 0.8, 0.8, 0.2 );
const vec3 evenSquareColor = vec3( 0.7, 0.5, 0.6 );
const vec3 oddSquareColor = vec3( 0.7, 0.7, 0.7);
const vec3 sphereColor = vec3( 0.0, 0.9, 0.1 );

// normals
const vec3 upDirection = vec3( 0.0, 1.0, 0.0 );
const vec3 groundOrigin = vec3( 0.0 );  // plane origin
const vec3 groundNormal = upDirection;  // plane normal

#define OBLIQUE_FLOOR

/** Finds the distance of a specified plane for a given ray
 *  @returns D if exists a point P in plane where P = rayOrigin + rayDirection * D
 *  @returns -1.0 if given ray does not intersect plane
 */
float planeCollision( vec3 ro, vec3 rd, vec3 po, vec3 pn )
{
    // a point lays in a plane when dot( planeOrigin - p, planeNormal ) is zero
    // for which d the expression (dot( (ro + rd * d) - po, pn )) is zero ?
    // solving by d...:            dot( ro, pn ) + dot( rd, pn ) * d - dot( po, pn ) = 0 
    float dist = dot( po - ro, pn ) / dot( rd, pn );
    
    float st = step( 0.0, -dot( rd, pn ) ); // dot( rd, -pn ) );
    
    return mix( -1.0, dist, st );
}

/** Returns the ground color given a point on it.
 */
vec3 ground( vec3 point )
{
    return mix( vec3( 0.0 ),
        mix( evenSquareColor, oddSquareColor,
#ifndef OBLIQUE_FLOOR
            mod( floor( point.z + iTime ) + floor( point.x ), 2.0 )
#else
            smoothstep( -0.01, 0.01, sin( point.z * 2.5 + iTime * 3. ) - cos( point.x * 2.5 + 1.9 ) )
#endif
        ),
        smoothstep( 16., 0., distance( point, groundOrigin ) )
    );
}

/**Returns the color of the envirornment given a ray and time
 */
vec3 background( vec3 ro, vec3 rd, float time )
{    
    vec3 light = normalize( vec3( sin(time), 0.6, cos(time) ));
    vec3 sunDirection = light;
    
    // sky factor: dot product with ray direction and up vector
    float sky = pow( max( 0.0, dot( upDirection, rd ) ), 1.0 );
    // sun factor: dot product with ray direction and light direction
    float sun = max( 0.0, dot( rd, sunDirection ) );
    float sunHaze = 64.0; // max( 2.0, 0.0 + (cos(t) * 256.0 ) );
    // ground color
    float groundDistance = planeCollision( ro, rd, groundOrigin, groundNormal );
    vec3 groundColor = ground( ro + rd * groundDistance );
    
    return pow( sky, 0.50 ) * skyColor
        + ( pow( sun, sunHaze ) + 0.2 * pow( sun, 2.0 ) ) * sunColor
        + step( 0.0, groundDistance ) * groundColor;
}

/**Detects if a given ray collide with a sphere
 * @returns D distance from ray origin and the hit point on the surface of the sphere
 * @returns -1 if ray does not intersect the sphere
 */
float sphereCollision( vec3 ro, vec3 rd, vec3 center, float r )
{
    // based on kig code
    vec3 rc = ro - center;
    float c = dot( rc, rc ) - ( r * r );
    float b = dot( rd, rc );
    float d = b*b - c;
    float t = -b - sqrt(abs(d));
    float st = step( 0.0, min( t, d ));
    
    
    return mix( -1.0, t, st );
}

/**Finds the sphere distance and normal of the point intersected by a given ray
 * @returns D distance from ray origin and the hit point on the surface of the sphere
 * @returns -1 if ray does not intersect the sphere
 */
float sphere( vec3 ro, vec3 rd, float time, out vec3 sphereNormal )
{
    vec3 sphereCenter = vec3( 0.3, 0.9 + cos( time * 1.579 ) * 0.4, 0.0 );
    const float sphereRadius = 1.0;
    
    float spheresDistance = sphereCollision( ro, rd, sphereCenter, sphereRadius ); // spheresDistance is -1 if no collision
    sphereNormal = normalize( sphereCenter - (ro+rd * spheresDistance) );          // normalizing the center with the hit point
    
    return spheresDistance;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (-1.0 + 2.0*fragCoord.xy / iResolution.xy) * vec2(iResolution.x/iResolution.y, 1.0);
    // ray origin
    vec3 ro = vec3( 0.0, 1.0, -2.0 - 1.0 + ( iMouse.y / iResolution.y ) );
    // ray direction with some movment determined by mouse
    vec3 rd = normalize( vec3( uv + vec2( (iMouse.x / iResolution.y) -0.5, 0. ), 1.0 ) );
    
    // detects collision with sphere
    vec3 sphereNormal;
    float spheresDistance = sphere( ro, rd, iTime, sphereNormal );
    // 
    vec3 bgColor = background( ro, rd, iTime );
    
    rd = reflect( rd, sphereNormal );
    
    vec3 sphereColor = background( ro, rd, iTime ) * sphereColor;
    
    vec3 outColor = mix( bgColor, sphereColor, step( 0.0, spheresDistance ) );
    
    fragColor = vec4(outColor,1.0);
}
