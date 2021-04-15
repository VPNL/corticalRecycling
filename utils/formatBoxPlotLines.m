function gcf = formatBoxPlotLines(gcf, boxPlotHandle)
    % change style of median lines
    medianlines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
    set(medianlines, 'Color', 'k');
    set(medianlines, 'LineWidth', 3);
    set(findobj(gcf, 'LineStyle', '--'), 'LineStyle', '-');
    % and other box plot lines
    set(boxPlotHandle, 'LineWidth', 2)
    set(boxPlotHandle, 'Color', 'k')

end