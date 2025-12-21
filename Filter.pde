class GaussianBlurFilter {
    int radius;
    int sigma;
    GaussianBlurFilter(int radius, int sigma) {
        this.radius = radius;
        this.sigma = sigma;
    }
    int clamp255(int v) {
        return v < 0 ? 0 : (v > 255 ? 255 : v);
    }

    float[] getkernel() {
        int size = 2 * radius + 1;
        float[] kernel = new float[size];
        float sum = 0;
        for (int i = -radius; i <= radius; i++) {
            float v = exp( - (i * i) / (2 * sigma * sigma));
            kernel[i + radius] = v;
            sum +=v;
        }
        for (int i = 0; i < size; i++) {
            kernel[i] /= sum;
        }
        return kernel;
    }
    PImage blurHorizontal(PImage src, float[] kernel, int radius) {
        PImage dst = createImage(src.width, src.height, RGB);
        src.loadPixels();
        dst.loadPixels();
        
        for (int y = 0; y < src.height; y++) {
            for (int x = 0; x < src.width; x++) {
                float r = 0, g = 0, b = 0;
                float a;
                int outA=0, outR=0, outG=0, outB=0;
                float sumR = 0, sumG = 0, sumB = 0, sumA = 0;
                for (int k = -radius; k <= radius; k++) {
                    int xx = constrain(x + k, 0, src.width - 1);
                    color c = src.pixels[y * src.width + xx];
                    float w = kernel[k + radius];

                    a=(c >> 24) & 0xFF;
                    r=(c >> 16) & 0xFF;
                    g=(c >> 8) & 0xFF;
                    b=c & 0xFF;

                    float af = a / 255.0f;
                    float pr = r * af;
                    float pg = g * af;
                    float pb = b * af;

                    sumR += pr * w;
                    sumG += pg * w;
                    sumB += pb * w;
                    sumA += a  * w;   

                    outA = clamp255((int)(sumA + 0.5f));

                    if (outA > 0) {
                    float invA = 255.0f / outA;
                    outR = clamp255((int)(sumR * invA + 0.5f));
                    outG = clamp255((int)(sumG * invA + 0.5f));
                    outB = clamp255((int)(sumB * invA + 0.5f));
                    } else {
                    outR = outG = outB = 0;
                    }
                }
                
                dst.pixels[y * src.width + x] = outA<<24 | outR<<16 | outG<<8 | outB;
        }
        }
        dst.updatePixels();
        return dst;
    }
    PImage blurVertical(PImage src, float[] kernel, int radius) {
        PImage dst = createImage(src.width, src.height, RGB);
        src.loadPixels();
        dst.loadPixels();
        
        for (int y = 0; y < src.height; y++) {
            for (int x = 0; x < src.width; x++) {
                float r = 0, g = 0, b = 0;
                float a;
                int outA=0, outR=0, outG=0, outB=0;
                float sumR = 0, sumG = 0, sumB = 0, sumA = 0;
                for (int k = -radius; k <= radius; k++) {
                    int yy = constrain(y + k, 0, src.height - 1);
                    color c = src.pixels[yy * src.width + x];
                    float w = kernel[k + radius];

                    a=(c >> 24) & 0xFF;
                    r=(c >> 16) & 0xFF;
                    g=(c >> 8) & 0xFF;
                    b=c & 0xFF;

                    float af = a / 255.0f;
                    float pr = r * af;
                    float pg = g * af;
                    float pb = b * af;

                    sumR += pr * w;
                    sumG += pg * w;
                    sumB += pb * w;
                    sumA += a  * w;   

                    outA = clamp255((int)(sumA + 0.5f));

                    if (outA > 0) {
                    float invA = 255.0f / outA;
                    outR = clamp255((int)(sumR * invA + 0.5f));
                    outG = clamp255((int)(sumG * invA + 0.5f));
                    outB = clamp255((int)(sumB * invA + 0.5f));
                    } else {
                    outR = outG = outB = 0;
                    }
                }
                
                dst.pixels[y * src.width + x] = outA<<24 | outR<<16 | outG<<8 | outB;
        }
        }
        dst.updatePixels();
        return dst;
    }
}

