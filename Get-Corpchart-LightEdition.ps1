

<#

            .Synopsis
            Draws a chart. Requires both .NET 3.5 and Microsoft Chart Controls for Microsoft .NET Framework 3.5 (http://www.microsoft.com/en-us/download/details.aspx?id=14422)
            Note: To get the more advance PowerShell Chart Script Wrapper, visit http://wp.me/p1eUZH-l5

            .DESCRIPTION
            Draws a chart. Requires both .NET 3.5 and Microsoft Chart Controls for Microsoft .NET Framework 3.5 (http://www.microsoft.com/en-us/download/details.aspx?id=14422).

            Input data:
             array of objects.You have to supply which are the two properties of the object to draw by supplying parameters (-obj_key and -obj-value)
   

   
            .PARAMETER Data
           Required. Array of objects.

            .PARAMETER Filepath
            Required. File path to save the chart like "c:\Chart1.PNG".

            .PARAMETER Obj_key
            Required. This represents the name of the object properties to be used as X Axis data. Optional parameter.

            .PARAMETER Obj_value
            Required. This represents the name of the object properties to be used as Y Axis data. Optional parameter.


            .PARAMETER Type 
            Chart type. Default is 'column'. Famous types are "Point", "FastPoint", "Bubble", "Line","Spline", "StepLine", "FastLine", "Bar","StackedBar", "StackedBar100", "Column",
                                 "StackedColumn", "StackedColumn100", "Area","SplineArea","StackedArea", "StackedArea100", "Pie", "Doughnut", "Stock", "Candlestick",
                                 "Range","SplineRange", "RangeBar", "RangeColumn", "Radar", "Polar", "ErrorBar", "BoxPlot", "Renko", "ThreeLineBreak", "Kagi", "PointAndFigure", "Funnel",
                                 "Pyramid"

            .PARAMETER Title_text
            Chart title. Default is empty title. Optional parameter.

            .PARAMETER Chartarea_Xtitle.  
            Chart X Axis title. Default is empty title. Optional parameter.

            .PARAMETER Chartarea_Ytitle  
            Chart Y Axis title. Default is empty title. Optional parameter.

            .PARAMETER Xaxis_Interval  
            Enter X Axis interval. Default is 1. Optional parameter.

            .PARAMETER Yaxis_Interval  
            Enter Y Axis interval. Usually you do not need to use this parameter. Optional parameter.

            .PARAMETER Chart_color  
            Enter chart column color. Only in case of 'column' or 'bar' chart types. Optional parameter.

            .PARAMETER Title_color  
            Enter chart title color. Default is 'red'. Optional parameter.

            .PARAMETER CollectedThreshold  
            Enter a threshold that all data values below it will be grouped as one item named 'Others'. This parameter takes an integer from 1 to 100. Optional parameter.

            .PARAMETER Sort  
            Sort the data option. Values are either 'asc' or 'dsc'. Optional parameter.

            .PARAMETER IsvalueShownAsLabel
            Switch parameter to indicate values appear as a label on the chart. Optional parameter.

            .PARAMETER ShowHighLow
            Switch parameter to indicate that the maximum and minimum values are highlighted in the chart.Optional parameter.

            .PARAMETER ShowLegend
            Switch parameter to determine if legend should be added to the chart. Optional parameter.
            

            .PARAMETER Append_date_title
            Append the current date to the title. Optional parameter.

            .PARAMETER Fix_label_alignment
            Only applicable if the chart type is Pie or Doughnut. If the data labels in the chart are overlapping, use the switch to fix it. Optional parameter.

            .PARAMETER Show_percentage_pie
            Only applicable if the chart type is Pie or Doughnut. This will show the data labels on the chart as percentages instead of actual data values. Optional parameter.



            .EXAMPLE
            Chart by supplying array of objects as input. We are interested in the Name and Population properties of the input objects.
            In this case, we should also use the -obj_key and -obj_value parameters to tell the function which properties to draw. Default chart type 'column' is used.
            PS C:\> Get-Corpchart-LightEdition -data $array_of_city_objects -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" 

            .EXAMPLE
            Specifying chart type as pie chart type.
            PS C:\> Get-Corpchart-LightEdition -data $cities -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" -type pie

            .EXAMPLE
            Specifying chart type as pie chart type. legend is shown.
            PS C:\> Get-Corpchart-LightEdition -data $cities -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" -type pie -showlegend 

            .EXAMPLE
            Specifying chart type as SplineArea chart type.
            PS C:\> Get-Corpchart-LightEdition -data $cities -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" -type SplineArea

            .EXAMPLE
            Specifying chart type as bar chart type, and specifying the title for the chart and x/y axis.
            PS C:\> Get-Corpchart-LightEdition -data $cities -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" -type Bar -title_text "people per country" -chartarea_Xtitle "cities" -chartarea_Ytitle "population"

            .EXAMPLE
            Specifying chart type as column chart type. Applying the -showHighLow switch to highlight the max and min values with different colors.
            PS C:\> Get-Corpchart-LightEdition -data $cities -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" -type column -showHighLow


            .EXAMPLE
            Chart with percentages shown on the pie/doughnut charts.
            PS C:\> Get-Corpchart-LightEdition -data $cities -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" -type Doughnut -Show_percentage_pie
           

            .EXAMPLE
            If the chart type is pie or doughnut, you can specify a threshold (percentage) that all data values below it, will be shown as one data item called (Others).
            PS C:\> Get-Corpchart-LightEdition -data $cities -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" -type Doughnut -CollectedThreshold 16

            .EXAMPLE
            Column chart with green columns.
            PS C:\> Get-Corpchart-LightEdition -data $cities -obj_key "Name" -obj_value "Population" -filepath "c:\chart.png" -chart_color green


            .Notes
            Script                   : Get-CorpCharts-LightEdition
            Last Updated             : April 23, 2014
            Version                  : 2.0 
            Author                   : Ammar Hasayen (Twitter @ammarhasayen)
            Email                    : me@ammarhasayen.com


            Note: To get the more advance PowerShell Chart Script Wrapper, visit http://ammarhasayen.com


            .Link
            http://ammarhasayen.com
#>



                [cmdletbinding()]  

                Param(

                #region REQUIRED parameters 
                
                        [Parameter(Position = 0,Mandatory = $true)]  
                        [ValidateNotNull()]
                        [ValidateNotNullorEmpty()]
                        [array]$data,   
                              
                        [Parameter(Position = 1,Mandatory = $true)]  
                        [ValidateNotNull()]
                        [ValidateNotNullorEmpty()]
                        [string]$filepath,

                        [Parameter(Position = 2,Mandatory = $true)]  
                        [ValidateNotNull()]
                        [ValidateNotNullorEmpty()]
                        [string]$obj_key,

                        [Parameter(Position = 3,Mandatory = $true)]  
                        [ValidateNotNull()]
                        [ValidateNotNullorEmpty()]
                        [string]$obj_value,
                        
        
                #endregion



                #region OPTIONAL parameters
        
                        # Chart type  
                         [ValidateSet("Point", "FastPoint", "Bubble", "Line","Spline", "StepLine", "FastLine", "Bar","StackedBar", "StackedBar100", "Column","StackedColumn", "StackedColumn100", "Area","SplineArea","StackedArea", "StackedArea100","Pie", "Doughnut", "Stock", "Candlestick","Range","SplineRange", "RangeBar", "RangeColumn","Radar", "Polar", "ErrorBar", "BoxPlot", "Renko","ThreeLineBreak", "Kagi", "PointAndFigure", "Funnel","Pyramid")]             
                        [string]$Type = "column",        

        
                        # Chart Titles
                        [string]$title_text = " ",

                        [string]$chartarea_Xtitle = " ",

                        [string]$chartarea_Ytitle = " ",

                        [int]$Xaxis_Interval = 1,

                        [int]$Yaxis_Interval,

                        [string]$chart_color = "MediumSlateBlue",

                        [string]$title_color="red",   

                        # Chart extra customization               
                        [string]$sort, 

                        [switch]$IsvalueShownAsLabel,
    
                        [switch]$showHighLow,
        
                        [switch]$showLegend,                        
        
                        [switch]$append_date_title,

                        [switch]$fix_label_alignment,
       
                        [switch]$show_percentage_pie,

                        [int]$CollectedThreshold
       
               #endregion OPTIONAL parameters
    
                )


                Begin {  

                        #region variables

                            New-Variable -Name currentDate -Option ReadOnly -Value (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -scope local 

                            New-Variable -Name font_Style1 -Option ReadOnly -Value (new-object system.drawing.font("ARIAL",18,[system.drawing.fontstyle]::bold))  -scope private 

                            New-Variable -Name font_style2 -Option ReadOnly -Value (new-object system.drawing.font("calibri",16,[system.drawing.fontstyle]::italic))  -scope private 

                            #chart background color
                            New-Variable -Name chartarea_backgroundcolor -Option ReadOnly  -Value "white" -scope private

           

            
                            #default chart dimension
                            $propChartDimension  = @{ "width"           = 1500;
                                                      "height"          = 800;
                                                      "left"            = 80;
                                                      "top"             = 100;
                                                      "name"            = "chart";
                                                      "BackColor"       = "white"
                                          } 

                            $ObjChartDimension = New-Object -TypeName psobject -Property $propChartDimension

                           

                            #hashtable to mark dimensions that will be scaled dynamically according to the number of input objects
                            $dynamicdimension = @{"column"="width";
                                                  "bar"   ="height"
                                                 }
                        #endregion variables



                        #region get class

                            # loading the data visualization .net class
                            [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

                        #endregion get class



                        #region internal functions

                            Function Get-CorpCalculateDim {

                                # Adjust width (in case of charts with 'column' type
                                # or height (in case of charts with 'bar' type according to the number of items
                                # Criteria :For each 15 item, dimention should expand by 1000

                                param ($count)

                                    [int]$v = ($count / 15)

                                    # if input items are less than 15 items (which gives 0 when doing int division by 15)
                                    if($v -eq 0) {$v=1}
                                    # if input items are more than 15 items
                                    else { $v=$v+1}

                                    return ($v*1000)

                            } #  Function Get-CorpCalculateDim


                        #endregion internal functions
            
            
                } # Function Get-Corpchart-LightEdition BEGIN Section


                Process { 

                        #region create chart 
                         
                            $var = $ErrorActionPreference
                            $ErrorActionPreference = "Stop"
                            try {
                                $chart  = new-object System.Windows.Forms.DataVisualization.Charting.Chart
                            }catch{
                                 Write-warning "Failed to create chart object. Make sure you have both .NET 3.5 and Microsoft Chart Controls for Microsoft .NET Framework 3.5 installed. Exiting"
                                 Write-warning "Clcik here to download thc chart controls(http://www.microsoft.com/en-us/download/details.aspx?id=14422)"
                                 Exit
                                 Throw "Failed to create chart object. Make sure you have both .NET 3.5 and Microsoft Chart Controls for Microsoft .NET Framework 3.5 installed. Exiting"
                            }finally {
                                $ErrorActionPreference = $var
                            }

                        #endregion create chart 

            
                        #region chart data

                            [void]$chart.Series.Add("Data") 
            
                            $array_keys   = @()
                            $array_values = @()

                            foreach ($object in $data) {

                                $array_keys += $object.$obj_key
                                $array_values += $object.$obj_value   

                            } # end foreach
            
                            $chart.Series["Data"].Points.DataBindXY($array_keys, $array_values)
            
                        #endregion 


                        #region chart type
                            $chart_type   =  $Type
                            $chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::$chart_type
            
                        #endregion


                        #region chart look and size : setting default chart dimensions 
            
                                $chart.width     = $ObjChartDimension.width
                                $chart.Height    = $ObjChartDimension.height
                                $chart.Left      = $ObjChartDimension.left
                                $chart.top       = $ObjChartDimension.top
                                $chart.Name      = $ObjChartDimension.name
                                $chart.BackColor = $ObjChartDimension.BackColor

                            # if the chart type is one that needs dynanmic dimensions according to the $dynamicdimension hashtable
                            # then we need to pull the dimension to be dynamically calculated
                            # example, if you are going to draw column chart type, then we will expand the width of the chart
                            # according to the number of items in the input data to give some room.
                            # while if you are going to draw a bar chart type, then we will expand the height accordingly.
                            if ($dynamicdimension.ContainsKey($chart_type)) {

                                # the variable item represents which dimension (according to the chart type) to  be dynamically calculated.
                                # for example, in case of column chart type, #item will be the width dimension.
                                $item = $dynamicdimension[$chart_type]
                                # the function Get-CorpCalculateDim will return the value of that item by giving it the number of items in the data input.
                                $chart.$item =  Get-CorpCalculateDim ($data.count)

                            } # if ($dynamicdimension.ContainsKey($chart_type))             

                        #endregion   


                        #region chart label

                        # if the $IsvalueShownAsLabel switch is specified, we will enable the label on the chart
                        $chart.Series["Data"].IsvalueShownAsLabel = $IsvalueShownAsLabel

                        #endregion


                        #region chart maxmin

                            # there is an option where the highest and lowest values in the input data can be highlighted by different colors
                            # if you specify the -showHighLow switch, the chart will do the highlighting

                            if ( $PSBoundParameters.ContainsKey("showHighLow") ) {

                                 #Find point with max value and change the colour of that value to red
                                 $maxValuePoint = $Chart.Series["Data"].Points.FindMaxByValue() 
                                 $maxValuePoint.Color = [System.Drawing.Color]::Red 
 
                                 #Find point with min value and change the colour of that value to green
                                 $minValuePoint = $Chart.Series["Data"].Points.FindMinByValue() 
                                 $minValuePoint.Color = [System.Drawing.Color]::Green
                            }

                        #endregion


                        #region Title

                            # putting the title of the chart

                            $title =New-Object System.Windows.Forms.DataVisualization.Charting.title
                            $chart.titles.add($title)            
                            $chart.titles[0].font         = $font_style1
                            $chart.titles[0].forecolor    = $title_color
                            $chart.Titles[0].Alignment    = "topLeft"

                            if ($PSBoundParameters.ContainsKey("append_date_title") ) {

                                $chart.titles[0].text   = ($title_text + "`n " + $currentDate )


                            }
                            else {
                
                                $chart.titles[0].text   = $title_text

                            }

                        #endregion


                        #region legend

                            # putting the legend of the chart if the -showlegend switch is used

                            if ( $PSBoundParameters.ContainsKey("showlegend") ) {

                                $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
                                $legend.BorderColor     = "Black"
                                $legend.Docking         = "Top"
                                $legend.Alignment       = "Center"
                                $legend.LegendStyle     = "Row"
                                $legend.MaximumAutoSize  = 100
                                $legend.BackColor       = [System.Drawing.Color]::Transparent  
                                $legend.shadowoffset= 1  
                    
                                $chart.Legends.Add($legend)

                            } # if ( $PSBoundParameters.ContainsKey("showlegend") )


                        #endregion


                        #region chart area

                            # chart area is where the X axis and Y axis titles and font style is to be configured.

                            $chartarea                = new-object system.windows.forms.datavisualization.charting.chartarea
                            $chartarea.backcolor      = $chartarea_backgroundcolor
                            $ChartArea.AxisX.Title    = $chartarea_Xtitle
                            $ChartArea.AxisX.TitleFont= $font_style2
                            $chartArea.AxisY.Title    = $chartarea_Ytitle             
                            $ChartArea.AxisY.TitleFont= $font_style2
                            $ChartArea.AxisX.Interval = $XAxis_Interval 
            
                            if ($PSBoundParameters.ContainsKey("YAxis_Interval") ) {
                                $ChartArea.AxisY.Interval = $YAxis_Interval           
                            }

                            $chart.ChartAreas.Add($chartarea)

                        #endregion                   

            
                        #region more configurations. 
            
                                #region Pie and Doughnuts configuration

                                    if (($chart_type -like "pie") -or ($chart_type -like "Doughnut") ) {
                                    # this applies only if the chart type is Pie or Doughnut.
                
                                        #region CollectedThreshold settings
                
                                        # sometimes, there is so much data to draw, you can specify a threshold (value between 1 and 100) 
                                        # which represents a percentage of the input data value, that is when any data item value is below it
                                        # the chart will group them under (Other) as one item with green color.
                                        if ( $PSBoundParameters.ContainsKey("CollectedThreshold") ) {

                                               $chart.Series["Data"]["CollectedThreshold"]           = $CollectedThreshold   
                                               $chart.Series["Data"]["CollectedLabel"]               = "Other"
                                               $chart.Series["Data"]["CollectedThresholdUsePercent"] = $true
                                               $chart.Series["Data"]["CollectedLegendText"]          = "Other"
                                               $chart.Series["Data"]["CollectedColor"]               = "green"

                                        } # if ( $PSBoundParameters.ContainsKey("CollectedThreshold") )

                                        #endregion

                                        #region fix alignment for labels

                                        # sometime the labels on the chart overlap above each other's making ugly look
                                        # the trick is make that chart as 3D with zero inclination
                                        # this can be done if you specify the -fix_label_alignment switch
                                        if ( $PSBoundParameters.ContainsKey("fix_label_alignment") ) {

                                            $chartArea.Area3DStyle.Enable3D = $true

                                            # if there is no inclination configured, that is if the chart is configured as 3D.
                                            # this validation is important to prevent overwriting an already configured inclination for 3D charts.
                                            if(-Not ($chartArea.Area3DStyle.Inclination)) { $chartArea.Area3DStyle.Inclination = 0 }
                

                                        } # if ( $PSBoundParameters.ContainsKey("fix_label_alignment") )
                
                                 #endregion

                            #region show data as percentage

                            # sometimes, it is better to show the data values as percentages instead of actual values.
                            # this can be done by using the -show_percentage_pie.
                            # this applies to both pie and doughnut chart types.
                            if ( $PSBoundParameters.ContainsKey("show_percentage_pie") ) {
                                   
                                #we will set the label to VLAX which is the X axis value then the percent with two decimals of the value (Y axis)
                                $chart.Series["Data"].Label = "#VALX (#PERCENT{P2})"

                                # on the legend, we will put the X axis value (VLAX).
                                $chart.Series["Data"].LegendText = "#VALX"                    

                            } # if ( $PSBoundParameters.ContainsKey("show_percentage_pie") )


                            #endregion

                        } # if (($chart_type -like "pie") -or ($chart_type -like "Doughnut") )

                        #endregion

                                #region Column and Bar configuration

                                    if (($chart_type -like "column") -or ($chart_type -like "bar") ) {
                                    # this applies only if the chart type is column or bar.
            
                                         # the X axis and Y axis line colors are set to DarkBlue.
                                         $chartarea.AxisX.LineColor =[System.Drawing.Color]::DarkBlue 
                                         $chartarea.AxisY.LineColor =[System.Drawing.Color]::DarkBlue                 

                                         # the title of the X axis and Y axis font color is set to DarkBlue.
                                         $ChartArea.AxisX.TitleForeColor =[System.Drawing.Color]::DarkBlue
                                         $ChartArea.AxisY.TitleForeColor =[System.Drawing.Color]::DarkBlue 
                 
                                         # configuring the internal chart grid.

                                         # enable customization of the grid
                                         $chartarea.AxisX.IsInterlaced = $true 
                                         # the grid line color
                                         $chartarea.AxisX.InterlacedColor = [System.Drawing.Color]::AliceBlue 
                                         # grid line type
                                         $chartarea.AxisX.ScaleBreakStyle.BreakLineStyle = "Straight"
                                         # grid area alternate color for both axises
                                         $chartarea.AxisX.MajorGrid.LineColor =[System.Drawing.Color]::LightSteelBlue 
                                         $chartarea.AxisY.MajorGrid.LineColor =[System.Drawing.Color]::LightSteelBlue 

                                         # configuring the chart column internal color
                                         $chart.Series["Data"].Color = $chart_color


                                    } # if (($chart_type -like "column") -or ($chart_type -like "bar") )

                                #endregion            

                                #region Configuration that applies to all chart types

                                         $chart.BorderlineWidth = 1
                                         $chart.BorderColor = [System.Drawing.Color]::black
                                         $chart.BorderDashStyle = "Solid" # values can be "Dash","DashDot","DashDotDot","Dot","NotSet","Solid"
                                         $chart.BorderSkin.SkinStyle = "Emboss"
                                #endregion

                                #region data sorting

                                 # showing the data sorted is a welcome thing. If you specify the -sort parameter, we will sort the data before drawing it.
             
                                 if ($sort -like "asc") {
                                    $Chart.Series["Data"].Sort([System.Windows.Forms.DataVisualization.Charting.PointSortOrder]::Ascending, "Y") 
                                 }
              
                                 elseif ($sort -like "dsc") {

                                    $Chart.Series["Data"].Sort([System.Windows.Forms.DataVisualization.Charting.PointSortOrder]::Descending, "Y") 
                                 }

                                 #endregion

                        #endregion
             


                } # Function Get-Corpchart-LightEdition PROCESS Section


                End {
                         $var = $ErrorActionPreference
                         $ErrorActionPreference = "Stop"
                         try{
                            $chart.SaveImage($filepath, "PNG")
                        }catch {
                            Throw "Failed to save chart at $filepath"
                        }
                        finally {
                        $ErrorActionPreference = $var
                        }


                } # Function Get-Corpchart-LightEdition END Section


