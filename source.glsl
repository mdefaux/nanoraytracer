
const vec3 skyColor = vec3( 0.4, 0.2, 1.0 );
const vec3 sunColor = vec3( 1.0, 1.0, 0.8 );
const vec3 upDirection = vec3( 0.0, 1.0, 0.0);

float groundCollision( vec3 ro, vec3 rd )
{
    const vec3 go = vec3( 0.0 );
    const vec3 gd = upDirection;
    
    // a point lays in a plane when dot( planeOrigin - p, planeNormal ) is zero
    // for which d the expression (dot( go - (ro + rd * d), gd )) is zero ?
    float dist = 1.0;
    
    float st = step( 0.0, dot( rd, -gd ) );
    
    return mix( -1.0, dist, st );
}

vec3 ground( vec3 point )
{
    return mix( vec3( 0.5, 0.1, 0.5 ), vec3( 0.2, 0.0, 0.5), floor( point.x + point.y ) );
}

vec3 background( vec3 ro, vec3 rd, float t )
{    
    vec3 light = normalize( vec3( sin(t), 0.6, cos(t) ));
    // vec3 light = normalize( vec3( sin(t) * 0.5, -sin(t), cos(t) ));
    vec3 sunDirection = light;
    
    // sky factor: dot product with ray direction and up vector
    float sky = pow( max( 0.0, dot( upDirection, rd ) ), 1.0 );
    // sun factor: dot product with ray direction and light direction
    float sun = max( 0.0, dot( rd, sunDirection ) );
    float sunHaze = 256.0; // max( 2.0, 0.0 + (cos(t) * 256.0 ) );
    // ground color
    float groundDistance = groundCollision( ro, rd );
    vec3 groundColor = ground( ro + rd * groundDistance );
    
    return pow( sky, 0.50 ) * skyColor 
        + pow( sun, sunHaze ) * sunColor
        + step( 0.0, groundDistance ) * groundColor;
}

float sphereCollision( vec3 ro, vec3 rd, vec3 center, float r )
{
    vec3 rc = ro - center;
    float c = dot( rc, rc ) - ( r * r );
    float b = dot( rd, rc );
    float d = b*b - c;
    float t = -b - sqrt(abs(d));
    float st = step( 0.0, min( t, d ));
    
    
    return mix( -1.0, t, st );
}

float sphere( vec3 ro, vec3 rd, vec3 center, float r )
{
    vec3 light = vec3( 0.0 );
    
    
    return -1.0;
}

vec3 scene( vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (-1.0 + 2.0*fragCoord.xy / iResolution.xy) * vec2(iResolution.x/iResolution.y, 1.0);
    // ray origin
    vec3 ro = vec3( 0.0, 1.0, -2.0 );
    // ray direction. add this to move camera: uv - 1.0 + ( iMouse.xy / iResolution.y ) 
    vec3 rd = normalize( vec3( uv - 1.0 + ( iMouse.xy / iResolution.y ), 1.0 ) );
    
    // detects collision with sphere
    vec3 sphereCenter = vec3( 0.0, 0.9 + cos( iTime ) * 0.4, 0.0 );
    float spheresDistance = sphereCollision( ro, rd, sphereCenter, 1.0 );
    // 
    vec3 bgColor = background( ro, rd, iTime );
    
    vec3 sphereNormal = normalize( sphereCenter - (ro+rd * spheresDistance) );
    rd = reflect( rd, sphereNormal );
    
    vec3 sphereColor = background( ro, rd, iTime ) * vec3( 0., 1.0, 0.0 );
    
    vec3 outColor = mix( bgColor, sphereColor, step( 0.0, spheresDistance ) );
    
    return outColor;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // draws the scene
    vec3 col = scene( fragCoord );
    // Output to screen
    fragColor = vec4(col,1.0);
}
