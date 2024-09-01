//Normal array based apporach, without  union find function
import java.util.*;

PImage img;
float threshold = 9;

void setup() 
{
    img = loadImage("Plate.jpg");
    size(1300, 1400);
    //img.resize(100,100);

    image(img, 0, 0);
    img.loadPixels();
    int[][] segments = graphBasedSegmentation(img, threshold);
    
    println(" Number of segments: " + segments.length);
    img.updatePixels();
    image(img, 0, img.height + 30);
    
}

int[][] graphBasedSegmentation(PImage image, float threshold) 
{
    int w = image.width;
    int h = image.height;
    int numPixels = w * h;

//-------------------- Step1:  Initialize each pixel as its own segment --------------------

    int[] segments = new int[numPixels];
    for (int i = 0; i < numPixels; i++) 
    {
        segments[i] = i;
    }

//-------------------- Create edges between adjacent pixels ----------
    List<Edge> edges_connected = new ArrayList<>();//Initializes an empty list to store the edges_connected between pixels.
  
    for (int y = 0; y < h; y++) //iterates over each row of the image.
    {
        for (int x = 0; x < w; x++) // iterates over each column  of the image.
        {
            int current = x + y * w;
            if (x < w - 1) // Horizontal Edge
            { 
                int next = (x + 1) + y * w;
                edges_connected.add(new Edge(current, next, weight(image.pixels[current], image.pixels[next])));
                
            }
            if (y < h - 1) // Vertical Edge
            { 
                int next = x + (y + 1) * w;
                edges_connected.add(new Edge(current, next, weight(image.pixels[current], image.pixels[next])));
                
            }
            if (x < w - 1 && y < h - 1) // Diagonal Edge (top-left to bottom-right)
            { 
                int next = (x + 1) + (y + 1) * w;
                edges_connected.add(new Edge(current, next, weight(image.pixels[current], image.pixels[next])));
             
            }
        }
    }

//-------------------- Step2:  Sort edges_connected by weight --------------------

    Collections.sort(edges_connected);//a utility class in the java used to sort the edges_connected in ascending order
    
    //print("Edges connected", edges_connected);

//------------- Step3: Checking,Processing the sorted edges_connected array list and merging them ----------------

    for (Edge edge : edges_connected)//Edge - data type, edge - Variable name, edges_connected - array having list of collected edges  
    {
        if (edge.weight <= threshold) 
        {
            int set1 = segments[edge.u];
            int set2 = segments[edge.v];
            if (set1 != set2) //if set1  and set2  are different, it means u and v are in different segments .
            {
                // Merge segments
                for (int i = 0; i < numPixels; i++) 
                {
                    if (segments[i] == set2) //if the current pixel belongs to set2,then merge it
                    {
                        segments[i] = set1;//For each element that belongs to set2, it changes its segment identifier to set1.
                    }
                }
            }
        }
        
    }

    // Collect unique segments
//HashSet is a function in java which does not allow duplicate elements in the array list
    Set<Integer> uniqueSegments = new HashSet<>(); //function and are used to efficiently store and retrieve data, HashSet is used to collect unique segment identifiers. to ignore duplicate ones
    for (int segment : segments) 
    {
        uniqueSegments.add(segment);
    }

    // Assign color RGB values to segments
    Map<Integer, Integer> segmentColors = new HashMap<>(); //HashMap is used to assign RGB values to the segemnts based on keyvalues .. Key -> unique segment identifier, Values -> RGB values
    for (int segment : uniqueSegments) 
    {
        segmentColors.put(segment, color(random(255), random(255), random(255)));
    }
    //print("The Segement colours are : ",segmentColors );

    // Assigining segment colours to all the pixels
    for (int i = 0; i < numPixels; i++) 
    {
        img.pixels[i] = segmentColors.get(segments[i]);//getting the segment colours from the segment and assigining to pixel
    }

    // Convert segments to array
    int[][] segmentsArray = new int[uniqueSegments.size()][];
    int i = 0;
    for (int segment : uniqueSegments) 
    {
        List<Integer> pixelList = new ArrayList<>(); //pixelList is created. This list will contain the indices of pixels belonging to the current segment.  
        for (int j = 0; j < numPixels; j++) //To collect the indices of pixels belonging to the current segment
        {
            if (segments[j] == segment) //If the pixel belongs to the current segment, its index is added to the pixelList.
            {
                pixelList.add(j);
            }
        }
        segmentsArray[i] = new int[pixelList.size()];//Convert Pixel List to Array
        for (int j = 0; j < pixelList.size(); j++) 
        {
            segmentsArray[i][j] = pixelList.get(j);//collecting the pixel indices of that particular segement
        }
        i++;
        
    }
    //println("The Segement Array is: ",segmentsArray.length);
    return segmentsArray;
}

// -------------------------- Calculating abs Intensity difference -----------------------------------------

float weight(int color1, int color2) // converting to grayscale and calculating the weights
{
  float intensity1 = brightness(color1);
  float intensity2 = brightness(color2);
  return abs(intensity1 - intensity2);
}


//float weight(int color1, int color2) //calculating the weights without converting to grayscale
//{
//    float red1 = red(color1);
//    float green1 = green(color1);
//    float blue1 = blue(color1);
    
//    float red2 = red(color2);
//    float green2 = green(color2);
//    float blue2 = blue(color2);
    
//    float colorDifference = abs(red1 - red2) + abs(green1 - green2) + abs(blue1 - blue2);
//    return colorDifference;
//}


// ------------------------- Edge Class------------------------------------------
class Edge implements Comparable<Edge> 
{
    int u;// instance variable representing one vertex of the edge
    int v;// instance variable representing the other vertex of the edge
    float weight; // instance variable representing the weight of the edge

    Edge(int u, int v, float weight) // Parameter
    {
        this.u = u;  // `this.u` refers to the instance variable `u`
        this.v = v;  // `this.v` refers to the instance variable `v`
        this.weight = weight; // `this.weight` refers to the instance variable `weight
    }

    public int compareTo(Edge other) 
    {
        return Float.compare(this.weight, other.weight);
    }


//-------------- The below line is used to print the u,v and weight values--------------------  
    @Override
    public String toString() 
    {
        return "Edge{u=" + u + ", v=" + v + ", weight=" + weight + "}";
    }
}
