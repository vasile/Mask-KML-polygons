<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:kml="http://www.opengis.net/kml/2.2"
    exclude-result-prefixes="kml">
    
    <!-- Provide custom mask via "stringparam" -->
    <xsl:param name="mask"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- #START ANALYZE POLYGONS, ORDER OF THESE TEMPLATES MATTERS ! -->
    <!-- 1. Multiple donut polygons  -->
    <xsl:template match="kml:MultiGeometry[kml:Polygon/kml:innerBoundaryIs]">
        <MultiGeometry xmlns="http://www.opengis.net/kml/2.2">
            <xsl:call-template name="renderMainPolygon">
                <xsl:with-param name="polygons" select="kml:Polygon"/>
            </xsl:call-template>
            <xsl:call-template name="renderIslands">
                <xsl:with-param name="polygons" select="kml:Polygon"/>
            </xsl:call-template>
        </MultiGeometry>
    </xsl:template>
    
    <!-- 2. Multiple simple polygons  -->
    <xsl:template match="kml:MultiGeometry">
        <xsl:call-template name="renderMainPolygon">
            <xsl:with-param name="polygons" select="kml:Polygon"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 3. Donut polygon   -->
    <xsl:template match="kml:Polygon[kml:innerBoundaryIs]">
        <MultiGeometry xmlns="http://www.opengis.net/kml/2.2">
            <xsl:call-template name="renderMainPolygon">
                <xsl:with-param name="polygons" select="."/>
            </xsl:call-template>
            <xsl:call-template name="renderIslands">
                <xsl:with-param name="polygons" select="."/>
            </xsl:call-template>
        </MultiGeometry>
    </xsl:template>
    
    <!-- 4. Simple polygon  -->
    <xsl:template match="kml:Polygon">
        <xsl:call-template name="renderMainPolygon">
            <xsl:with-param name="polygons" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- #END ANALYZE -->
    
    <!-- Main polygon defined by the mask and the holes (former outer shells) -->
    <xsl:template name="renderMainPolygon">
        <xsl:param name="polygons" />
        <Polygon xmlns="http://www.opengis.net/kml/2.2">
            <!-- BIG(universe) mask -->
            <outerBoundaryIs xmlns="http://www.opengis.net/kml/2.2">
                <LinearRing xmlns="http://www.opengis.net/kml/2.2">
                    <coordinates xmlns="http://www.opengis.net/kml/2.2">
                        <xsl:choose>
                            <xsl:when test="$mask != ''">
                                <xsl:value-of select="$mask"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>5,45.5 12,45.5 12,48 5,48 5,45.5</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </coordinates>
                </LinearRing>
            </outerBoundaryIs>
            <!-- NEW HOLES(former outer shells) -->
            <xsl:for-each select="$polygons/kml:outerBoundaryIs">
                <innerBoundaryIs xmlns="http://www.opengis.net/kml/2.2">
                    <xsl:copy-of select="kml:LinearRing"/>
                </innerBoundaryIs>
            </xsl:for-each>
        </Polygon>
    </xsl:template>
    
    <!-- New stand-alone polygons (former donuts) -->
    <xsl:template name="renderIslands">
        <xsl:param name="polygons" />
        <xsl:for-each select="$polygons/kml:innerBoundaryIs">
            <Polygon xmlns="http://www.opengis.net/kml/2.2">
                <outerBoundaryIs xmlns="http://www.opengis.net/kml/2.2">
                    <xsl:copy-of select="kml:LinearRing"/>
                </outerBoundaryIs>
            </Polygon>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>