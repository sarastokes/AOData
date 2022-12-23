function tf = isDateEqual(date1, date2)
    arguments
        date1       datetime 
        date2 
    end
    if ~isdatetime(date2)
        tf = false;
        return
    end
    
    if isequal(date1.Year, date2.Year) && isequal(date1.Month, date2.Month) ...
            && isequal(date1.Day, date2.Day)
        tf = true;
    else
        tf = false;
    end