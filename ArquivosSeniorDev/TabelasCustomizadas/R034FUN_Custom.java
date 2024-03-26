package TabelasCustomizadas;

import com.senior.dataset.annotation.Entity;
import com.senior.dataset.annotation.Field;
import com.senior.rh.entities.readonly.IR034FUN;

@Entity
public interface R034FUN_Custom extends IR034FUN {

	@Field(description = "Pagar Extras")
	int getUSU_PAGEXT();

	void setUSU_PAGEXT(int USU_PAGEXT);

	boolean isUSU_PAGEXTNull();

	void setUSU_PAGEXTNull();

}
