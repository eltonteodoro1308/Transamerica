Attribute VB_Name = "Módulo1"
Function myconcat(rng As Range) As String

    Dim x As Integer
    
    For x = 1 To rng.Cells.Count
    
       myconcat = myconcat & rng.Cells.Item(1, x)
       
       If x < rng.Cells.Count Then
       
        myconcat = myconcat & ";"
       
       End If
        
    Next x

End Function
