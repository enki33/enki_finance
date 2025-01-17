-- Add missing RLS policies for category table
CREATE POLICY "Usuarios pueden crear categorías" ON public.category 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar categorías" ON public.category 
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar categorías" ON public.category 
    FOR DELETE USING (auth.role() = 'authenticated');

-- Add missing RLS policies for subcategory table
CREATE POLICY "Usuarios pueden crear subcategorías" ON public.subcategory 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar subcategorías" ON public.subcategory 
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar subcategorías" ON public.subcategory 
    FOR DELETE USING (auth.role() = 'authenticated'); 