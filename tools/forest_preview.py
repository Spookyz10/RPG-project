"""Orthographic inspection of generated Part/WedgePart geometry, not a Studio render."""
import math
from pathlib import Path


def render_models(lines, output):
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont

    groups = {}
    for line in lines:
        if not line.startswith("GEOM|"):
            continue
        fields = line.split("|")
        if fields[1] not in ("AmberwoodMatriarch", "WoodlandFungus"):
            continue
        groups.setdefault((fields[1], fields[10]), []).append(fields)
    tree = next(value for key, value in groups.items() if key[0] == "AmberwoodMatriarch")
    fungus = next(value for key, value in groups.items() if key[0] == "WoodlandFungus")
    image = Image.new("RGB", (1500, 1100), "#edf0df")
    draw = ImageDraw.Draw(image)
    fonts = Path("C:/Windows/Fonts")
    title = ImageFont.truetype(str(fonts / "segoeuib.ttf"), 32)
    text = ImageFont.truetype(str(fonts / "segoeui.ttf"), 20)
    draw.text((50, 30), "FOREST / ESTUDO DA GEOMETRIA LOW POLY", font=title, fill="#294b39")
    draw.text((50, 79), "Peças produzidas pelo gerador · projeção offline, sem a iluminação do Studio", font=text, fill="#526652")

    def dot(a, b):
        return sum(x*y for x, y in zip(a, b))

    def sub(a, b):
        return tuple(x-y for x, y in zip(a, b))

    def cross(a, b):
        return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])

    def project(p):
        return dot(p, (0.8, 0, -0.6)), dot(p, (-0.24, 0.916515, -0.32)), dot(p, (0.55, 0.4, 0.73))

    for records, panel, label in [(tree, (55, 170, 940, 940), "Árvore: copas facetadas, galhos internos e bases enterradas"),
                                   (fungus, (1010, 510, 1440, 920), "Cogumelo: caule ligado ao chapéu")]:
        faces = []
        for f in records:
            center = tuple(map(float, f[3:6]))
            rgb = tuple(map(float, f[13:16]))
            axes = [tuple(map(float, f[start:start+3])) for start in (16, 19, 22)]
            x, y, z = (float(value)/2 for value in f[25:28])
            if f[11] == "WedgePart":
                vertices = [(-x,-y,-z),(x,-y,-z),(x,-y,z),(-x,-y,z),(-x,y,z),(x,y,z)]
                polygons = [(0,1,2,3),(3,2,5,4),(0,4,5,1),(0,3,4),(1,5,2)]
            else:
                vertices = [(-x,-y,-z),(x,-y,-z),(x,-y,z),(-x,-y,z),(-x,y,-z),(x,y,-z),(x,y,z),(-x,y,z)]
                polygons = [(0,1,2,3),(4,7,6,5),(0,4,5,1),(3,2,6,7),(0,3,7,4),(1,5,6,2)]
            world = [tuple(center[k] + sum(p[j]*axes[j][k] for j in range(3)) for k in range(3)) for p in vertices]
            for indices in polygons:
                points = [world[index] for index in indices]
                normal = cross(sub(points[1],points[0]), sub(points[2],points[0]))
                length = math.sqrt(dot(normal,normal))
                intensity = 0.62 + 0.38*abs(dot(normal,(-0.35,0.87,-0.34)))/max(length,1e-9)
                projected = [project(p) for p in points]
                faces.append((sum(p[2] for p in projected)/len(projected), projected,
                              tuple(int(min(255,c*255*intensity)) for c in rgb)))
        all_points = [p for _, poly, _ in faces for p in poly]
        left, right = min(p[0] for p in all_points), max(p[0] for p in all_points)
        low, high = min(p[1] for p in all_points), max(p[1] for p in all_points)
        scale = min((panel[2]-panel[0])/(right-left), (panel[3]-panel[1])/(high-low))
        ox = (panel[0]+panel[2])/2-(left+right)/2*scale
        oy = panel[3]+low*scale
        draw.ellipse((panel[0]+50,panel[3]-25,panel[2]-50,panel[3]+20), fill="#cfd7bc")
        # Depth per pixel avoids painter-order artifacts where crown volumes meet.
        canvas=np.array(image)
        depth=np.full((image.height,image.width),-np.inf)
        for _, poly, color in faces:
            screen=[(ox+p[0]*scale,oy-p[1]*scale,p[2]) for p in poly]
            for i in range(1,len(screen)-1):
                a,b,c=screen[0],screen[i],screen[i+1]
                x0=max(0,int(min(a[0],b[0],c[0])))
                x1=min(image.width-1,math.ceil(max(a[0],b[0],c[0])))
                y0=max(0,int(min(a[1],b[1],c[1])))
                y1=min(image.height-1,math.ceil(max(a[1],b[1],c[1])))
                divisor=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
                if abs(divisor)<1e-8 or x1<x0 or y1<y0:
                    continue
                yy,xx=np.mgrid[y0:y1+1,x0:x1+1]
                u=((b[1]-c[1])*(xx-c[0])+(c[0]-b[0])*(yy-c[1]))/divisor
                v=((c[1]-a[1])*(xx-c[0])+(a[0]-c[0])*(yy-c[1]))/divisor
                w=1-u-v
                z=u*a[2]+v*b[2]+w*c[2]
                view=depth[y0:y1+1,x0:x1+1]
                mask=(u>=-1e-6)&(v>=-1e-6)&(w>=-1e-6)&(z>view)
                view[mask]=z[mask]
                canvas[y0:y1+1,x0:x1+1][mask]=color
        image=Image.fromarray(canvas)
        draw=ImageDraw.Draw(image)
        draw.text((panel[0], 975), label, font=text, fill="#294b39")
    draw.text((50,1040), "Esta prévia verifica formas e encaixes. Aparência final e navegação ainda precisam do Studio.", font=text, fill="#526652")
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output)
